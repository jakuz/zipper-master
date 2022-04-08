require "rails_helper"

RSpec.describe User, type: :model do
  context "relations" do
    it "has_many attachments" do
      expect(User.reflect_on_association(:attachments).macro).to match(:has_many)
    end
  end

  context "validations" do
    it "not valid without email" do
      expect(User.new(email: nil, password: "password")).not_to be_valid
    end

    it "not valid without password" do
      expect(User.new(email: "email@example.com", password: nil)).not_to be_valid
    end

    it "not valid with invalid email" do
      expect(User.new(email: "email@example", password: "password")).not_to be_valid
    end

    it "valid with password and valid email" do
      expect(User.new(email: "email@example.com", password: "password")).to be_valid
    end
  end
end
