class AddUserRefToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_reference :attachments, :user, foreign_key: true
  end
end
