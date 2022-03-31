class MakeUserRefToAttachmentsNotnull < ActiveRecord::Migration[6.1]

  # just an example; in real scenarios usually something should be done 
  # with already existing (but not assigned to any user) attachments;
  # furthermore, it is required when ones wants to set NOT NULL constraint
  # on user_id column in attachments table

  def up
    attachments = Attachment.where({ user_id: nil })
    if attachments.empty?
      change_column_null :attachments, :user_id, false
    else
      user = User.create(name: 'Generic User', email: 'generic-user@example.com', password: 'generic')
      change_column_null :attachments, :user_id, false, user.id
    end
  end
  
  def down
    change_column_null :attachments, :user_id, true
	
    if user = User.find_by(email: 'generic-user@example.com')
      Attachment.where({ user_id: user.id }).each do |attachment|
        attachment.update_column(:user_id, nil)
      end
      user.destroy
    end
  end
end
