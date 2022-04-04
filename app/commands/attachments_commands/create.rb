module AttachmentsCommands
  class Create
    def initialize(attachment_params, current_user)
      @params = attachment_params
      @user = current_user
      @logger = Rails.logger
    end
  
    def call
      create_zipped_attachment
    end
  
    private

    def create_zipped_attachment
      create_zipped_file
      remove_unzipped_files

      save_attachment_in_db
    end

    def create_zipped_file
      @zip_file = ActionDispatch::Http::UploadedFile.new(tempfile: tempfile_with_zipped_files)
      @zip_file.original_filename = zip_file_name
      @zip_file.content_type = 'application/zip'
      @zip_file.headers = @params[:files][0].headers
    end

    def tempfile_with_zipped_files
      tempfile = Tempfile.new

      encrypted_stream = Zip::OutputStream.write_buffer(::StringIO.new(''), encrypter) do |zos|
        @params[:files].each do |file|
          zos.put_next_entry(file.original_filename)
          zos.write(File.open(file.tempfile.path, 'r').read)
        end
      end
      encrypted_stream.rewind

      tempfile.binmode
      tempfile.write(encrypted_stream.read)
      
      tempfile
    end

    def encrypter
      Zip::TraditionalEncrypter.new(zip_password)
    end

    def zip_password
      @zip_password ||= SecureRandom.hex(16)
    end

    def zip_file_name
      "#{Time.now.strftime("%Y%m%d_%H%M")}_files_#{SecureRandom.hex(3)}.zip"
    end

    def remove_unzipped_files
      @params[:files].each do |file|
        file.tempfile.close
        file.tempfile.unlink 
      end

      @params.delete(:files)
    end

    def save_attachment_in_db
      attachment = Attachment.create!({ file: @zip_file, user_id: @user ? @user.id : nil })
      return {
        filename:       @zip_file.original_filename,
        file_password:  zip_password,
        file_url:       attachment.file.attachment.blob.url
      }
    rescue ActiveRecord::RecordInvalid => e
      @logger.error "#{e.class} while saving attachment: #{e.message}"
      @logger.debug "Record: #{e.record.inspect}"
      e
    end
  end
end
