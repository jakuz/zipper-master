class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment].to_unsafe_h)

    if @attachment.save
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    @attachments = Attachment.all
  end
end
