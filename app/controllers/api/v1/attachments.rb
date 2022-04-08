module API
  module V1

    class Attachments < Grape::API
      include Defaults
      include CustomTypes
      include AttachmentsCommands
      helpers Helpers::UploadHelpers

      before do
        set_active_storage_host
      end

      namespace :attachments do

        http_basic do |email, password|
          @user = User.find_by_email(email)
          @user && @user.authenticate(password) 
        end


        # example of CURL request:
        # URL='http://127.0.0.1:3000/api/v1/attachments/upload'
        # curl -u jan@example.com:password -F files[]=@file1.txt -F files[]=@file2.txt $URL 
        desc "Upload file(s)"
        params do
          requires :files, type: Array[JSON] do
            requires :tempfile, type: Tempfile
            requires :filename, type: String
            requires :type, type: String
            requires :head, type: String
          end
        end
        post :upload do
          resp = AttachmentsCommands::Create.new(action_dispatch_files, @user).call
          return resp unless resp.is_a? Exception
            
          if resp.instance_of? ActiveRecord::RecordInvalid
            error!({ error: "#{resp.message}" }, 422)
          else
            raise resp
          end
        end

        desc "Return user's attachments"
        params do
          use :pagination
        end
        get "" do
          attachments = Attachment.all.where({ user_id: @user.id }).order(created_at: :desc).
            page(params[:page]).per(params[:per_page])

          attachments.map do |attachment|
            {
              filename: attachment.file.filename.to_s,
              size: attachment.file.byte_size.to_s(:human_size),
              created_at: attachment.created_at.to_s,
              file_url: attachment.file.attachment.blob.url
            }
          end
        end
      end
    end

  end
end
