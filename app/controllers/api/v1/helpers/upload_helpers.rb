module API
  module V1
    module Helpers
      module UploadHelpers
        extend Grape::API::Helpers

        def action_dispatch_files
          converted_files = { files: [] }

          permitted_params[:files].each do |file|
            converted_file = ActionDispatch::Http::UploadedFile.new(file)
            converted_files[:files].append converted_file
          end
          converted_files
        end

      end
    end
  end
end
