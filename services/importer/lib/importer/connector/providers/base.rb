# encoding: utf-8

# Base class for Connector Providers
# that use FDW to import data through a foreign table

module CartoDB
  module Importer2
    class Connector
      class Provider

        def errors
          errors = []
          invalid_params = @params.keys - accepted_parameters - ['provider']
          missing_parameters = required_parameters - @params.keys
          if missing_parameters.present?
            errors << "Missing required parameters #{missing_parameters * ','}"
          end
          errors << "Invalid parameters: #{invalid_params * ', '}" if invalid_params.present?
          errors
        end

        def valid?
          errors.empty?
        end

        def validate!
          errors = self.errors
          raise InvalidParametersError.new(errors * "\n") if errors.present?
        end

        # Name of the table to be imported
        def table_name
          must_be_defined_in_derived_class
        end

        # SQL code to create the FDW server
        def create_server_command(_server_name)
          must_be_defined_in_derived_class
        end

        # SQL code to create the usermap for the user and postgres roles
        def create_usermap_command(_server_name, _username)
          must_be_defined_in_derived_class
        end

        # SQL code to create the foreign table used for importing
        def create_foreign_table_command(_server_name, _schema_name, _table_name, _foreign_prefix, _username)
          must_be_defined_in_derived_class
        end

        # SQL code to drop the FDW server (and user mapping)
        def drop_server_command(server_name)
          fdw_drop_server server_name
        end

        # SQL code to drop the foreign table
        def drop_foreign_table_command(schema_name, table_name)
          fdw_drop_foreign_table schema_name, table_name
        end

        # Parameters required by this connector provider
        def required_parameters
          must_be_defined_in_derived_class
        end

        # Optional parameters accepted by this connector provider
        def optional_parameters
          must_be_defined_in_derived_class
        end

        # Parameters accepted by this connector provider
        def accepted_parameters
          required_parameters + optional_parameters
        end

        def initialize(params = {})
          @params = params
        end

        private

        include CartoDB::Importer2::Connector::Support
        include FdwSupport

        def must_be_defined_in_derived_class
          raise "Method #{caller_locations(1, 1)[0].label} must be defined in derived class"
        end

      end

    end
  end
end
