require 'rails_helper'

RSpec.describe API::V1::Attachments, type: :request do

  before(:context) do
    Attachment.delete_all
    User.delete_all
  end

  context 'user not authorized' do
    describe 'GET /api/v1/attachments' do
      it 'returns http status 401 and empty body' do
        get '/api/v1/attachments'
        expect(response).to have_http_status(401)
        expect(response.body).to eq ''
      end
    end

    describe 'POST /api/v1/attachments/upload' do
      it 'returns http status 401 and empty body' do
        post '/api/v1/attachments/upload'
        expect(response).to have_http_status(401)
        expect(response.body).to eq ''
      end
    end
  end

  context "user authorized" do
    before(:context) do
      create_test_user
    end

    after(:context) do
      Attachment.delete_all
      User.delete_all
    end

    describe "POST /api/v1/attachments/upload" do
      context "valid multipart/form-data content attached" do
        it "returns http status 201" do
          post "/api/v1/attachments/upload",
            params: { files: stub_uploaded_files }, headers: base_auth_header
  
          expect(response).to have_http_status(201)
        end
  
        it "returns JSON with filename, file_password and file_url" do
          post "/api/v1/attachments/upload",
            params: { files: stub_uploaded_files }, headers: base_auth_header
  
            expect(response.content_type).to eq("application/json")
            expect(JSON.parse(response.body, symbolize_names: true).keys).
              to contain_exactly(:filename, :file_password, :file_url)
        end 

        it "creates one attachment in db" do
          request = -> { post "/api/v1/attachments/upload",
            params: { files: stub_uploaded_files }, headers: base_auth_header }

          expect(request).to change{ Attachment.count }.by(1)
        end
      end

      context "invalid content attached" do
        it "returns http status 500 when content is not a multipart/form-data" do
          post "/api/v1/attachments/upload",
            params: { files: [ 'file1.jpg', 'file2.txt'] }, headers: base_auth_header
  
          expect(response).to have_http_status(500)
        end
        it "returns http status 500 when _files_ key is missing in params" do
          post "/api/v1/attachments/upload",
            params: { different_key: stub_uploaded_files }, headers: base_auth_header
  
          expect(response).to have_http_status(500)
        end
      end
    end

    describe "GET /api/v1/attachments" do
      it "returns http status 200 and collection in body" do
        get "/api/v1/attachments", headers: base_auth_header
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to be_instance_of(Array)
      end
    end
  end
end