require "rails_helper"

RSpec.describe Attachment, type: :model do

  context "relations" do
    it "belongs_to user" do
      expect(Attachment.reflect_on_association(:user).macro).to match(:belongs_to)
    end
  end
end
