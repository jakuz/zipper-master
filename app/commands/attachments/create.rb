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
    update_file_attributes_in_params
    save_attachment
  end

  def add_zipped_file_to_params
    @params[:attachment][:file].tempfile = zip_file
  end

  def zip_file
    filename = @params[:attachment][:file].original_filename
    tempfile = Tempfile.new(filename)

    begin
      encrypted_stream = Zip::OutputStream.write_buffer(::StringIO.new(''), encrypter) do |zos|

        zos.put_next_entry(filename)
        zos.write(File.open(@params[:attachment][:file].tempfile.path, 'r').read)
      end

      encrypted_stream.rewind

      tempfile.binmode
      tempfile.write(encrypted_stream.read)

    ensure
      clear_original_tempfile
    end
    
    tempfile
  end

  def encrypter
    Zip::TraditionalEncrypter.new(@params[:password])
  end

  def clear_original_tempfile
    @params[:attachment][:file].tempfile.close
    @params[:attachment][:file].tempfile.unlink    
  end

  def update_file_attributes_in_params
    @params[:attachment][:file].original_filename << '.zip'
    @params[:attachment][:file].content_type = 'application/zip'
  end

  def save_attachment
    Attachment.new(@params[:attachment].to_unsafe_h).save!
  end
 end