class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
  end

  def create
    Attachments::Create.new(params_with_password).call
    flash_decryption_password
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid => invalid
    @attachment = invalid.record
    flash_upload_error
    render :new
  end

  def index
    @attachments = Attachment.all
  end

  private

  def params_with_password
    params[:password] = SecureRandom.hex(16)
    params
  end

  def flash_decryption_password
    filename = params[:attachment][:file].original_filename
    flash[:notice] = "Plik '#{filename}' został pomyślnie załadowany \
      i zaszyfrowany hasłem: #{params[:password]}"
  end

  def flash_upload_error
    flash.now[:alert] = "Coś poszło nie tak... Spróbuj ponownie"
  end
end
