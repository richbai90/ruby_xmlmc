#Warning! Here Be Dragons. This code is unfinished and should not be used with any certainty
require_relative 'interface'
require_relative 'query'


module Xmlmc
  module Api
    INTERFACE = Xmlmc::Interface.new
    #Handles all the Session Operations of the XMLMC API
    class Session
      attr_reader :xmlmc
      #@param [string] server The ipaddress or hostname for the Supportworks server
      #@param [string] port The port to send API requests to
      def initialize (server, port = '5015')
        @xmlmc = INTERFACE
        set_endpoint server, port
      end

      def set_endpoint (server, port)
        @xmlmc.set_endpoint server, port
      end

      def switch_port(port='5015')
        @xmlmc.switch_port port
      end

      #logoff current session
      def analyst_logoff
        invoke :analystLogoff
      end

      #start a new helpdesk session with analyst credentials
      #@param [string] userid analyst id to login
      #@param [string] password analyst password
      def analyst_logon (userid, password)
        params = {

            :userID => userid,
            :password => password
        }

        invoke :analystLogon, params
      end

      def analyst_logon_trust (userid, secret)
        params = {
            :userID => userid,
            :secretKey => secret
        }
        invoke :analystLogonTrust, params
      end

      #bind an existing session to the current session
      #@param [string] token session token see get_session
      def bind_session (token)
        params = {
            :sessionid => token
        }
        invoke :bindSession, params
      end

      #change the selfservice password of the currently logged in customer.
      #@param [string] old_password
      #@param [string] new_password
      def change_password (old_password, new_password)
        params = {
            :oldPassword => old_password,
            :newPassword => new_password
        }
        invoke :changePassword, params
      end

      def convert_date_time (iso_date)
        params = {
            :inputText => iso_date
        }
        invoke :convertDateTimeInText, params
      end

      def get_session_info
        invoke :getSessionInfo2
      end

      def has_right (right)
        params = {
            :userRight => right
        }
        invoke :hasRight, params
      end

      def is_session_valid
        invoke :isSessionValid
      end

      def self_service_logoff
        invoke :selfServiceLogoff
      end

      def self_service_logon (customer, password, instance = 'ITSM')
        params = {
            :customerId => customer,
            :password => password,
            :selfServiceInstance => instance
        }
        invoke :selfServiceLogon, params
      end

      def set_database_right table, right, allowed
        params = {
            :tableName => table,
            :rightFlag => right,
            :rightAllowed => allowed
        }
        invoke :setDatabaseRight, params
      end

      def set_output_validation validate
        params = {
            :validateResultMessage => validate
        }
        invoke :setOutputValidation, params
      end

      def set_user_right right_class, right_flag, right_allowed
        params = {
            :rightClass => right_class,
            :rightFlag => right_flag,
            :rightAllowed => right_allowed
        }
        invoke :setUserRight, params
      end

      def set_variable session_variable = {}
        params = {
            :sessionVariable => session_variable
        }
        invoke :setVariable, params
      end

      def switch_analyst_context group, analyst = nil
        params = {
            :groupId => group
        }
        if analyst
          params[:analystId] = analyst
        end
        invoke :switchAnalystContext, params
      end

      private
      def invoke method, params = {}, data = {}
        @xmlmc.switch_port('5015')
        @xmlmc.invoke :session, method, params, data
      end
    end
    class Data
      attr_reader :xmlmc
      attr_reader :query
      attr_accessor :query_results

      def initialize
        @xmlmc = INTERFACE
      end

      def add_record table, data, return_modified_data = false
        params = {
            :table => table,
            :returnModifiedData => return_modified_data
        }
        invoke :addRecord, params, data
      end

      def delete_record table, id
        params = {
            :table => table,
            :keyValue => id
        }
        invoke :deleteRecord, params
      end

      def get_column_info table, db = 'swdata'
        params = {
            :database => db,
            :table => table
        }
        invoke :getColumnInfo, params
      end

      def get_record table, id, db = 'swdata', meta = false, format = false, raw_values = false
        params = {
            :database => db,
            :table => table,
            :keyValue => id,
            :formatValues => format,
            :returnMeta => meta,
            :returnRawValues => raw_values
        }
        invoke :getRecord, params
      end

      def get_stored_queries folder
        params = {
            :folder => folder
        }
        invoke :getStoredQueries, params
      end

      def run_data_import conf, data
        params = {
            :confFileName => conf,
            :dataFileName => data
        }
        invoke :runDataImport, params
      end

      def sql_query query, rs = false, max = 0, db = 'swdata', meta = false, format = false, raw_values = false
        params = {
            :database => db,
            :query => query,
            :formatValues => format,
            :returnMeta => meta,
            :maxResults => max,
            :returnRawValues => raw_values
        }
        recordset = invoke :sqlQuery, params
        if rs
          return recordset
        end
        Xmlmc::Query.new recordset, @xmlmc
      end

      def update_record table, data, return_data = false
        params = {
            :table => table,
            :returnModifiedData => return_data
        }
        invoke :updateRecord, params, data
      end

      def invoke_stored_query query, parameters
        param_string = ''
        parameters.each do |k, v|
          if param_string != ''
            param_string += '&'
          end
          param_string += "#{k}=#{v}"
        end
        params = {
            :storedQuery => query,
            :parameters => param_string
        }
        recordset = invoke :invokeStoredQuery, params
        Xmlmc::Query.new recordset, @xmlmc
      end

      private
      def invoke method, params = {}, data = {}
        @xmlmc.switch_port('5015')
        @xmlmc.invoke :data, method, params, data

      end
    end
    class Helpdesk
      attr_reader :xmlmc

      def initialize
        @xmlmc = INTERFACE
      end

      def log_call cust, sla, desc, callclass = 'Incident', addtl_call_vals = {}
        params = {
            :callClass => callclass,
            :slaName => sla,
            :customerId => cust,
            :updateMessage => desc,
            :additionalCallValues => addtl_call_vals
        }

        if addtl_call_vals[:opencall].respond_to?(:each)
          if addtl_call_vals[:opencall][:itsm_title].respond_to?(:upcase)
            #do nothing
          else
            params[:additionalCallValues][:opencall][:itsm_title] = desc
          end
        else
          params[:additionalCallValues][:opencall]= {}
          params[:additionalCallValues][:opencall][:itsm_title] = desc
        end
        invoke :logNewCall, params
      end

      def update_call callref, time, text
        params = {
            :callref => callref,
            :timeSpent => time,
            :description => text
        }
        invoke :updateCalls, params
      end

      def accept_call callref, sla_response = true
        params = {
            :callref => callref,
            :markAsSLAResponse => sla_response
        }
        invoke :acceptCalls, params
      end

      def resolve_call callref, time, text
        params = {
            :callref => callref,
            :timeSpent => time,
            :description => text
        }
        invoke :resolveCalls, params
      end

      def log_incident cust, sla, desc, addtl_call_vals = {}
        log_call cust, sla, desc, 'Incident', addtl_call_vals
      end

      def log_service_request cust, sla, desc, service, process
        _workflow_id = nil
        _stage_id = nil
        _stage_title = nil
        _service = nil

        data = Xmlmc::Api::Data.new
        query = data.sql_query "select pk_auto_id from config_itemi where ck_config_item = '#{service}'"
        query.each do
          _service = query.field 'pk_auto_id'
        end
        query = data.sql_query "select workflow.pk_workflow_id, workflow.fk_firststage_id, stage.title from bpm_workflow workflow join bpm_stage stage on stage.pk_stage_id = workflow.fk_firststage_id where workflow.pk_workflow_id = '#{process}'"
        query.each do
          _workflow_id = query.field 'pk_workflow_id'
          _stage_id = query.field 'fk_firststage_id'
          _stage_title = query.field 'title'
        end

        extra_data = {
            :opencall => {
                :bpm_workflow_id => _workflow_id,
                :bpm_stage_title => _stage_title
            },
            :cmn_rel_opencall_ci => {
                :fk_ci_auto_id => _service,
                :relcode => 'Request'
            }
        }

        if _workflow_id === nil
          puts 'workflow is nil'
          return
        end

        log_call cust, sla, desc, 'Service Request', extra_data
      end

      def log_change cust, sla, desc
        log_call cust, sla, desc, 'Change Request'
      end

      def add_files_to_diary callref, udid, file, server_file
        params = {
            :callRef => callref,
            :diaryUpdateId => udid,
            :fileAttachment => file,
            :serverFileAttachment => server_file
        }
        invoke :addFilesToCallDiaryItem, params
      end

      private
      def invoke method, params = {}, data = {}
        @xmlmc.switch_port('5015')
        @xmlmc.invoke :helpdesk, method, params, data

      end
    end
    class Knowledge_base
      def initialize
        @xmlmc = INTERFACE
        @invoke_count = 0
      end

      def invoke method, params = {}, data = {}
        #Try 3 times to establish a connection
        @xmlmc.switch_port('5015')
        @invoke_count+=1
        results = @xmlmc.invoke :knowledgebase, method, params, data
        if !(results.respond_to? :each)
          if @invoke_count > 3
            return
          end
          if @xmlmc.last_error == 'Invalid session. Please establish a session first'
            session = new Session
            session.analyst_logon @xmlmc.user_id, @xmlmc.user_pass
            @invoke_count+=1
            invoke method, params, data
          end
        end
        results
      end

      def article_add (article)
        params = {}
        if article.respond_to? :each
          article.each do |p, v|
            params[p] = v
          end
        end
        if params.length > 0
          invoke :articleAdd, params
        end
      end

      def article_delete (ref, force = false)
        params = {
            :docRef => ref,
            :forceDelete => force
        }
        invoke :articleDelete, params
      end

      def article_update (ref, updates = {})
        params = {
            :docRef => ref
        }
        if updates.length > 0
          updates.each do |p, v|
            params[p] = v
          end
        end
        invoke :articleUpdate, params
      end

      def catalog_add (name)
        params = {
            :name => name
        }
        invoke :catalogAdd, params
      end

      def catalog_delete (id)
        params = {
            :catalogId => id
        }
        invoke :catalogDelete, params
      end

      def catalog_list
        invoke :catalogList
      end

      def catalog_rename (id, name)
        params = {
            :catalogId => id,
            :newName => name
        }
        invoke :catalogRename, params
      end

      def document_add (doc)
        params = {}
        if doc.respond_to? :each
          doc.each do |p, v|
            params[p] = v
          end
        end
        if params.length > 0
          invoke :documentAdd, params
        end
      end

      def document_delete (ref)
        params = {
            :docRef => ref
        }
        invoke :documentDelete, params
      end

      def document_list
        invoke :documentList
      end

      def document_get_info (ref)
        params = {
            :docRef => ref
        }
        invoke :documentGetInfo, params
      end

      def document_get_callref ref
        invoke :documentGetCallref, {:docRef => ref}
      end

      def document_get_url ref
        invoke(:documentGetUrl, {:docRef => ref})
      end
    end
    class Mail
      attr_reader :xmlmc

      def initialize
        @xmlmc = INTERFACE
      end

      def get_mailbox_list (type=:all)

        case type
          when :shared, 'shared'
            type = 2
          when :personal, 'personal'
            type = 1
          when :all, 'all'
        end

        if type.is_a? Symbol or type.is_a? String
          params = {}
        else
          params = {:type => type}
          invoke :getMailboxList, params
        end
      end

      private
      def invoke method, params = {}, data = {}
        #verify that we are sending it to port 5014
        @xmlmc.switch_port('5014')
        @xmlmc.invoke :mail, method, params, data
      end
    end
  end
end
