require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#flash_class" do
    it "returns alert-success class name when notice string inputted" do
      expect(helper.flash_class("notice")).to eql("alert-success")
    end
    
    it "returns alert-danger class name when alert string inputted" do
      expect(helper.flash_class("alert")).to eql("alert-danger")
    end
  end
end
