require 'rails_helper'

RSpec.describe API::V1::Users, type: :request do

  before(:context) do
    Attachment.delete_all
    User.delete_all
  end

  after(:context) do
    User.delete_all
  end

  describe "POST /api/v1/users/register" do
    context "valid registration data provided" do
      it "returns http status 201" do
        post "/api/v1/users/register",
          params: { name: 'John', email: 'test@example.com', password: 'testpass' }

        expect(response).to have_http_status(201)
      end

      it "returns JSON with created User object" do
        post "/api/v1/users/register",
          params: { name: 'John', email: 'test@example.com', password: 'testpass' }

          expect(response.content_type).to eq("application/json")
          expect(JSON.parse(response.body)).to eq(User.last.as_json)
      end   
    end

    context "invalid registration data provided" do
      it "returns http status 422 when invalid email" do
        post "/api/v1/users/register",
          params: { name: 'John', email: 'test@example', password: 'testpass' }

        expect(response).to have_http_status(422)
      end

      it "returns http status 422 when password empty" do
        post "/api/v1/users/register",
          params: { name: 'John', email: 'test@example.com', password: '' }

        expect(response).to have_http_status(422)
      end 

      it "returns http status 500 when _password_ key missing" do
        post "/api/v1/users/register",
          params: { name: 'John', email: 'test@example.com' }

        expect(response).to have_http_status(500)
      end 
    end
  end
end