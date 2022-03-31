class Attachment < ApplicationRecord
  has_one_attached :file

  belongs_to :user

  paginates_per 10
end
