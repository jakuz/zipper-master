class Attachments::Create
  def initialize(params)
    @params = params
    @logger = Rails.logger
  end
 
  def call
    if create_zipped_attachment
      return {
        zip_filename: @zip_file.original_filename,
        zip_password: zip_password
      }
    else
      false
    end
  end
 
  private

  def create_zipped_attachment
    create_zipped_file
    remove_unzipped_files

    save_attachment_in_db
  end

  def create_zipped_file
    @zip_file = @params[:files][0].dup

    @zip_file.tempfile = tempfile_with_zipped_files
    @zip_file.original_filename = zip_file_name
    @zip_file.content_type = 'application/zip'
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
    Attachment.new({ file: @zip_file }).save!
  rescue ActiveRecord::RecordInvalid => invalid
    @logger.error "Error while saving attachment: #{invalid.message}"
    @logger.debug "Record: #{invalid.record.inspect}"
    
    false
  end
 end
