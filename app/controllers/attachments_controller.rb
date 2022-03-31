class AttachmentsController < ApplicationController

  before_action :authorize

  def new
    @attachment = Attachment.new
  end

  def create
    if @create_resp = Attachments::Create.new(attachment_params, current_user).call
      flash_decryption_password
      redirect_to root_path
    else
      flash_upload_error
      @attachment = Attachment.new
      render :new
    end 
  end

  def index
    @attachments = Attachment.all.where({ user_id: current_user.id }).
      order(created_at: :desc).page params[:page]
  end

  private

  def attachment_params
    params.require(:attachment).permit(files: [])
  end

  def flash_decryption_password
    flash[:notice] = "Pomyślnie załadowano plik(i). \
      Hasło do utworzonego załącznika '#{@create_resp[:zip_filename]}', \
      to: #{@create_resp[:zip_password]}"
  end

  def flash_upload_error
    flash.now[:alert] = "Coś poszło nie tak... Spróbuj ponownie"
  end
end
