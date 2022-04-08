require "rails_helper"

RSpec.describe "Sessions", type: :request do
  before(:context) do
    Attachment.delete_all
    User.delete_all
  end

  let(:re_form) {/<form.*>/}
  let(:re_login_email) {/name=.login\[email\]./}
  let(:re_login_password) {/name=.login\[password\]./}
  let(:re_wrong_cred) {/Błędny email i\/lub hasło. Spróbuj ponownie./}
  let(:re_successful_login) {/Pomyślnie zalogowano użytkownika/}
  let(:re_successful_logout) {/Pomyślnie wylogowano użytkownika/}

  describe "GET /login" do
    it "returns http success" do
      get "/login"
      expect(response).to have_http_status(:success)
    end

    it "contains form with email and password" do
      get "/login"
      expect(response.body).to match(re_form)
      expect(response.body).to match(re_login_email)
      expect(response.body).to match(re_login_password)
    end
  end

  describe "POST /login" do
    before(:context) do
      User.create(email: "test@example.com", password: "testpass") 
    end

    after(:context) do
      User.delete_all
    end

    let(:cred_valid) { { login: { email: "test@example.com", password: "testpass" } } }
    let(:cred_invalid_pass) { { login: { email: "test@example.com", password: "wrong-pass" } } }
    let(:cred_invalid_email) { { login: { email: "test@example", password: "testpass" } } }
    let(:cred_missing_email) { { login: { email: "", password: "testpass" } } }
    let(:cred_missing_pass) { { login: { email: "test@example.com", password: "" } } }
    let(:cred_missing_cred) { { login: { email: "", password: "" } } }

    context "valid credentials provided" do
      it "redirects to root and returns http success" do
        post "/login", params: cred_valid
        expect(response).to redirect_to root_path
        follow_redirect!
        expect(response).to have_http_status(:success)
      end

      it "shows successful login message" do
        post "/login", params: cred_valid
        expect(response).to redirect_to root_path
        follow_redirect!
        expect(flash[:notice]).to match(re_successful_login)
      end
    end

    context "invalid credentials provided" do
      it "doesnt redirect and shows warning message when invalid password" do
        post "/login", params: cred_invalid_pass
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_wrong_cred)
      end
 
      it "doesnt redirect and shows warning message when invalid email" do
        post "/login", params: cred_invalid_email
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_wrong_cred)
      end
 
      it "doesnt redirect and shows warning message when password missing" do
        post "/login", params: cred_missing_pass
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_wrong_cred)
      end
 
      it "doesnt redirect and shows warning message when email missing" do
        post "/login", params: cred_missing_email
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_wrong_cred)
      end
 
      it "doesnt redirect and shows warning message when password and email missing" do
        post "/login", params: cred_missing_cred
        expect(response).not_to have_http_status(:redirect)
        expect(flash[:alert]).to match(re_wrong_cred)
      end
    end
  end

  describe "DELETE /logout" do
    it "redirects to login page and returns http success" do
      delete "/logout"
      expect(response).to redirect_to login_path
      follow_redirect!
      expect(response).to have_http_status(:success)
    end

    it "shows successful logout message" do
      delete "/logout"
      expect(response).to redirect_to login_path
      follow_redirect!
      expect(flash[:notice]).to match(re_successful_logout)
    end
  end
end
