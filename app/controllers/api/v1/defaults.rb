module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json

        helpers do
          params :pagination do
            optional :page, type: Integer
            optional :per_page, type: Integer
          end

          def permitted_params
            @permitted_params ||= declared(params, 
               include_missing: false)
          end

          def logger
            Rails.logger
          end

          def set_active_storage_host
            ActiveStorage::Current.host = 'http://localhost:3000' \
              if ActiveStorage::Current.host.blank?
          end
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          logger.error "#{e.class} while searching for object: #{e.message}\n#{e.backtrace[0]}"
          error!({ error: e.message }, 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          logger.error "#{e.class} while saving object: #{e.message}\n#{e.backtrace[0]}"
          error!({ error: e.message }, 422)
        end

        rescue_from :all do |e|
          logger.error "#{e.class}: #{e.message}\n#{e.backtrace[0]}"
          logger.debug "#{e.backtrace.join("\n")}"
          error!({ error: 'Internal server error.' }, 500)
        end
      end
    end
  end
end
