class CreateAttachments < ActiveRecord::Migration[6.1]
  def change
    create_table :attachments do |t|
      t.string :name
      t.integer :size
      t.datetime :expires_at

      t.timestamps
    end
  end
end
