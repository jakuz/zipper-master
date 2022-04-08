module ApiSpecHelpers
  require 'rails_helper'

  def test_credentials
    {
      email: 'test@example.com',
      pass: 'testpass'
    }
  end

  def create_test_user
    User.create(email: test_credentials[:email], password: test_credentials[:pass])    
  end

  def base_auth_header
    {
      HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(test_credentials[:email], test_credentials[:pass])
    }
  end

  def stub_uploaded_files
    pic_file = fixture_file_upload(file_fixture('pic_test.jpg'))
    doc_file = fixture_file_upload(file_fixture('doc_test.txt'))
    
    [ pic_file, doc_file ]
  end
end
