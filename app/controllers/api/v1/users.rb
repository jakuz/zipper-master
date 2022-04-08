module API
  module V1
    class Users < Grape::API
      include Defaults

      namespace :users do

        desc "Register new user"
        params do
          requires :email, type: String, desc: "User's email"
          requires :password, type: String, desc: "User's password"
          optional :name, type: String, desc: "User's name"
        end
        post :register do
          User.create!({
            email: permitted_params[:email],
            password: permitted_params[:password],
            name: permitted_params[:name] 
            })
        end
      end

    end
  end
end