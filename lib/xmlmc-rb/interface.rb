module Xmlmc
  class Interface
    attr_reader :token
    attr_reader :last_error
    attr_accessor :user_id
    attr_accessor :user_pass

    def initialize server = 'localhost', port = '5015'
      set_endpoint(server, port)
      @last_error = nil
      @token = nil
      @xml = nil
    end

    def set_endpoint server, port = '5015'
      uri = "http://#{server}:#{port}"
      @uri = URI uri
    end

    def invoke service, method, params = {}, data = {}
      if method == :analystLogon
        @user_id = params[:userID]
        @user_pass = params[:password]
      end
      method_call = build_method_call params, method, service, data
      response = send_xml method_call
      if response
        response = parse_xml_response response, service

      else
        @last_error
        return
      end
      response
    end

    def build_method_call params, method, service, data = {}
      @xml = Nokogiri::XML::Builder.new do |xml|
        xml.methodCall :service => service, :method => method do
          if params.length > 0
            xml.params do
              params.each do |p, v|
                if v.respond_to? :each
                  prepare_complex_param p, v, xml
                else
                  if p.to_s.downcase.index 'password'
                    v = Base64.encode64 v
                  elsif p == 'secretKey'
                    v = Base64.encode64 v
                  end
                  xml.send p, v
                end
              end
            end
          end
          if data.length > 0
            xml.data do
              data.each do |field, val|
                if val.respond_to? :each
                  prepare_complex_param field, val, xml
                else
                  xml.send field, val
                end
              end
            end
          end
        end
      end
      @xml.to_xml
    end

    def prep_for_hash string, make_sym = false
      if make_sym
        string.gsub! /[\n\r\t]+/, ''
        string.gsub! /\s{2,}/, ''
        string.gsub! /\s/, '_'
        string.gsub! /\W+/, ''
        string[0] = string[0].downcase
        final_string = string.to_sym
      else
        string.gsub! /[\n\r\t]+/, ''
        string.gsub! /\s{2,}/, ''
        final_string = string
      end
      final_string
    end

    private
    def prepare_complex_param root, param, xml
      xml.send root do
        param.each do |elem, val|
          if val.respond_to? :each
            prepare_complex_param elem, val, xml
          else
            if root.to_s != 'data'
              if elem.to_s.downcase.index 'password'
                val = Base64.encode64 val
              elsif elem == 'secretKey'
                val = Base64.encode64 val
              end
            end
            xml.send elem, val
          end
        end
      end
    end


    def send_xml xml
      uri = @uri
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new uri.request_uri
      request.body = xml
      request.content_type = 'text/xmlmc'
      request['accept'] = 'text/xmlmc'
      if @token
        request['cookie'] = @token
      end
      response = http.request request
      if response.code == '200'
        @token = response['set-cookie']
        response.body
      else
        handle_error "HTTP Response #{response.code}. This may indicate a problem on your network."
      end
    end


    def parse_xml_response xml, service
      results = {}
      xml = Nokogiri::XML xml
      status = xml.xpath 'string(//@status)'
      if status == 'fail'
        error = xml.xpath 'string(//error)'
        handle_error error
        return
      end

      params = xml.xpath '/methodCallResult/params/*'
      data = xml.xpath '/methodCallResult/data/*'
      params.each do |param|
        param_name = param.xpath 'name()'
        param_value = param.xpath 'string()'
        param_name = prep_for_hash param_name, true
        if param_name == :rowsEffected
          param_value = param_value.to_i
        end
        results[param_name] = param_value
      end

      if data.length > 0
        if service == :data || service == 'data'
          recordset = xml.xpath '/methodCallResult/data/record/*'
          from_get_record = true

          if recordset.length <= 0
            recordset = xml.xpath '/methodCallResult/data/rowData/*'
            from_get_record = false
          end

          if from_get_record
            results[:data] = {}
            recordset.each do |field|
              field_name = field.xpath 'name()'
              field_value = field.xpath 'string()'
              field_name = prep_for_hash field_name, true
              field_value = prep_for_hash field_value
              results[:data][field_name] = field_value
            end
          else
            results[:data] = []
            recordset.each do |row|
              row_hash = {}
              columns = row.xpath '*'
              columns.each do |column|
                column_name = column.xpath 'name()'
                column_value = column.xpath 'string()'
                column_name = prep_for_hash column_name, true
                column_value = prep_for_hash column_value
                row_hash[column_name] = column_value
              end
              results[:data] << row_hash
            end
          end


          #todo: meta = parse_meta xml, from_get_record
        else
          results[:data] = []
          data.each do |folder|
            folder = folder.xpath '*'
            obj = {}
            folder.each do |p|
              name = p.xpath 'name()'
              value = p.xpath 'string()'
              obj[name] = value
            end
            results[:data] << obj
          end
        end
      end
      results
    end


    def handle_error error
      begin
        @last_error = error
        raise @last_error
      rescue
        puts error
      end
    end
  end
end