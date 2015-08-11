#Warning! Here Be Dragons. This code is unfinished and should not be used with any certainty
require_relative 'interface'



module Xmlmc
  module Api
    INTERFACE = Xmlmc::Interface.new
    class Session
      attr_reader :xmlmc
      def initialize server, port = '5015'
        @xmlmc = INTERFACE
        @xmlmc.set_endpoint server, port
      end

      def analyst_logoff
        invoke :analystLogoff
      end

      def analyst_logon userid, password
        params = {

            :userID => userid,
            :password => password
        }

        invoke :analystLogon, params
      end

      def analyst_logon_trust userid, secret
        params = {
            :userID => userid,
            :secretKey => secret
        }
        invoke :analystLogonTrust, params
      end

      def bind_session token
        params = {
            :sessionid => token
        }
        invoke :bindSession, params
      end

      def change_password old_password, new_password
        params = {
            :oldPassword => old_password,
            :newPassword => new_password
        }
        invoke :changePassword, params
      end

      def convert_date_time iso_date
        params = {
            :inputText => iso_date
        }
        invoke :convertDateTimeInText, params
      end

      def get_session_info
        invoke :getSessionInfo2
      end

      def has_right right
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

      def self_service_logon customer, password, instance = 'ITSM'
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
            groupId => group
        }
        if analyst
          params[:analystId] = analyst
        end
        invoke :switchAnalystContext, params
      end
      private
      def invoke method, params = {}, data = {}
        @xmlmc.invoke :session, method, params, data
      end
    end
    class Data
      attr_reader :xmlmc

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

      def sql_query query, max = 0, db = 'swdata', meta = false, format = false, raw_values = false
        params = {
            :database => db,
            :query => query,
            :formatValues => format,
            :returnMeta => meta,
            :maxResults => max,
            :returnRawValues => raw_values
        }
        invoke :sqlQuery, params
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
        invoke :invokeStoredQuery, params
      end

      private
      def invoke method, params = {}, data = {}
        @xmlmc.invoke :data, method, params, data

      end
    end
  end
end
