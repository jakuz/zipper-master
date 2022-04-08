require "rails_helper"

RSpec.describe "Attachments", type: :request do
  before(:context) do
    Attachment.delete_all
    User.delete_all
  end

  context "user is not logged-in" do
    let(:re_logging_necessary) {/Musisz się zalogować, aby uzyskać dostęp do tej strony/}

    describe "GET /" do
      it "redirects to login page and shows warning message" do
        get "/"
        expect(response).to redirect_to login_path
        expect(flash[:alert]).to match(re_logging_necessary)
      end
    end

    describe "GET /attachments/new" do
      it "redirects to login page and shows warning message" do
        get "/attachments/new"
        expect(response).to redirect_to login_path
        expect(flash[:alert]).to match(re_logging_necessary)
      end
    end

    describe "POST /attachments" do
      it "redirects to login page and shows warning message" do
        post "/attachments"
        expect(response).to redirect_to login_path
        expect(flash[:alert]).to match(re_logging_necessary)
      end
    end
    
  end

  context "user is logged-in" do
    before(:context) do
      create_and_log_in_user
    end

    let(:pic_file) { fixture_file_upload(file_fixture('pic_test.jpg')) }
    let(:doc_file) { fixture_file_upload(file_fixture('doc_test.txt')) }
    let(:re_success) {/Pomyślnie załadowano plik\(i\)\.\s+Hasło do utworzonego załącznika '\w+\.zip',\s+to: [a-z0-9]+/}
    let(:re_files_missing) {/Należy wybrać co najmniej jeden plik/}
    let(:re_table) {/<table.*>/}
    let(:re_form) {/<form.*>/}

    describe "GET /" do
      it "returns http success and contains table" do
        get "/"
        expect(response).to have_http_status(:success)
        expect(response.body).to match(re_table)
      end
    end

    describe "GET /attachments/new" do
      it "returns http success and contains form" do
        get "/attachments/new"
        expect(response).to have_http_status(:success)
        expect(response.body).to match(re_form)
      end
    end

    describe "POST /attachments" do
      it "shows warning message when files not attached" do
        post "/attachments", params: {}

        expect(flash[:alert]).to match(re_files_missing)
      end

      it "redirects to root and returns http success when files uploaded" do
        post "/attachments", params: { attachment: { files: [ pic_file, doc_file ] } }
        
        expect(response).to redirect_to root_path
        follow_redirect!
        expect(response).to have_http_status(:success)
      end

      it "shows zip file name and password when files uploaded" do
        post "/attachments", params: { attachment: { files: [ pic_file, doc_file ] } }
        
        expect(response).to redirect_to root_path
        follow_redirect!
        expect(flash[:notice]).to match(re_success)
      end

      it "creates one attachment when files uploaded" do
        request = -> { post "/attachments",
          params: { attachment: { files: [ pic_file, doc_file ] } } }
        
        expect(request).to change{ Attachment.count }.by(1)
      end
    end
  end

  def create_and_log_in_user
    User.create(email: "test@example.com", password: "testpass")
    post "/login", params: { login: { email: "test@example.com", password: "testpass" } }
    follow_redirect!
  end
end
