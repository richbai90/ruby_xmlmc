module Xmlmc
  class Record
    attr_reader :rs
    attr_reader :iface
    attr_accessor :current_row
    attr_accessor :current_field

    def initialize(rs, iface, current_row = 0)
      @rs = rs
      @iface = iface
      @current_row = current_row
      @current_field = nil
    end

    def each(&code)
      field = 0
      @current_field = rs.keys[field]
      @rs.each do |i|
        code.call i
        field +=1
        @current_field = rs.keys[field]
      end
      @current_field = nil
    end

    def field(field)
      f = @iface.prep_for_hash field, true
      @rs[f]
    end
  end
end