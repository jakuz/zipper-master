require "rails_helper"

RSpec.describe "Users", type: :request do
  before(:context) do
    Attachment.delete_all
    User.delete_all
  end

  let(:re_form) {/<form.*>/}
  let(:re_user_name) {/name=.user\[name\]./}
  let(:re_user_email) {/name=.user\[email\]./}
  let(:re_user_password) {/name=.user\[password\]./}
  let(:re_user_password_confirmation) {/name=.user\[password_confirmation\]./}
  let(:re_registration_failure) {/Coś poszło nie tak\.\.\. Upewnij się, czy poprawnie wpisałeś email i hasło./}
  let(:re_registration_success) {/Konto utworzone pomyślnie/}

  describe "GET /users/new" do
    it "returns http success" do
      get "/users/new"
      expect(response).to have_http_status(:success)
    end

    it "contains form with name, email, password and password confirmation" do
      get "/users/new"
      expect(response.body).to match(re_form)
      expect(response.body).to match(re_user_name)
      expect(response.body).to match(re_user_email)
      expect(response.body).to match(re_user_password)
      expect(response.body).to match(re_user_password_confirmation)
    end
  end

  describe "POST /users" do
    before(:example) do
      User.delete_all 
    end

    after(:context) do
      User.delete_all
    end

    let(:cred_valid) { { user: { email: "test@example.com", password: "testpass", password_confirmation: "testpass" } } }
    let(:cred_invalid_email) { { user: { email: "test@example", password: "testpass", password_confirmation: "testpass" } } }
    let(:cred_missing_email) { { user: { email: "", password: "testpass", password_confirmation: "testpass" } } }
    let(:cred_missing_pass) { { user: { email: "test@example.com", password: "", password_confirmation: "testpass" } } }
    let(:cred_missing_pass_conf) { { user: { email: "test@example.com", password: "testpass", password_confirmation: "" } } }
    let(:cred_missing_cred) { { user: { email: "", password: "", password_confirmation: "" } } }

    context "valid credentials provided" do
      it "redirects to root and returns http success" do
        post "/users", params: cred_valid
        expect(response).to redirect_to root_path
        follow_redirect!
        expect(response).to have_http_status(:success)
      end

      it "shows successful registration message" do
        post "/users", params: cred_valid
        expect(response).to redirect_to root_path
        follow_redirect!
        expect(flash[:notice]).to match(re_registration_success)
      end
    end

    context "invalid credentials provided" do
      it "doesnt redirect and shows warning message when invalid email" do
        post "/users", params: cred_invalid_email
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_registration_failure)
      end
 
      it "doesnt redirect and shows warning message when password missing" do
        post "/users", params: cred_missing_pass
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_registration_failure)
      end
 
      it "doesnt redirect and shows warning message when password confirmation missing" do
        post "/users", params: cred_missing_pass_conf
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_registration_failure)
      end
 
      it "doesnt redirect and shows warning message when email missing" do
        post "/users", params: cred_missing_email
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_registration_failure)
      end
 
      it "doesnt redirect and shows warning message when password, password confirmation and email missing" do
        post "/users", params: cred_missing_cred
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_registration_failure)
      end
    end
  end
end
