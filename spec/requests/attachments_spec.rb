require 'rails_helper'

RSpec.describe "Attachments", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/attachments/new"
      expect(response).to have_http_status(:success)
    end
  end
end
