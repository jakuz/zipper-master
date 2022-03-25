class Attachments::Create
  def initialize(params)
    @params = params
  end
 
  def call
    create_zipped_attachment
  end
 
  private

  def create_zipped_attachment
    add_zipped_file_to_params
    remove_original_files_from_params
    save_attachment_in_db
  end

  def add_zipped_file_to_params
    file = @params[:attachment].merge!(file:
      @params[:attachment][:files][0].dup)[:file]

    file.tempfile = get_tempfile_with_zipped_files
    file.original_filename = zip_file_name
    file.content_type = 'application/zip'
  end

  def get_tempfile_with_zipped_files
    files = @params[:attachment][:files]
    tempfile = Tempfile.new

    encrypted_stream = Zip::OutputStream.write_buffer(::StringIO.new(''), encrypter) do |zos|
      files.each do |file|
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
    Zip::TraditionalEncrypter.new(@params[:password])
  end

  def zip_file_name
    "#{Time.now.strftime("%Y%m%d_%H%M")}_files_#{SecureRandom.hex(3)}.zip"
  end

  def remove_original_files_from_params
    @params[:attachment][:files].each do |file|
      file.tempfile.close
      file.tempfile.unlink 
    end

    @params[:attachment].delete(:files)
  end

  def save_attachment_in_db
    Attachment.new(@params[:attachment].to_unsafe_h).save!
  end
 end