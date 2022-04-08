require "rails_helper"

RSpec.describe AttachmentsCommands::Create do

  describe "#call" do
    before(:context) do
      ActiveStorage::Current.host = "http://localhost:3000"
      Attachment.delete_all
      User.delete_all
    end

    let(:user) { User.create(email: "test@example.com", password: "testpass") }
    
    context "wrong params provided" do

      it "returns RecordInvalid exception when user not provided" do
        expect(described_class.new(stub_uploaded_files, nil).call).to be_instance_of(ActiveRecord::RecordInvalid)
      end

      it "raises exception when uploaded_files not provided" do
        expect { described_class.new(nil, user).call }.to raise_exception(NoMethodError)
      end

      it "raises exception when no params provided" do
        expect { described_class.new(nil, nil).call }.to raise_exception(NoMethodError)
      end

    end

    context "valid params provided" do
      it "creates one attachment" do 
        expect { described_class.new(stub_uploaded_files, user).call }.to change { Attachment.count }.by(1) 
      end

      it "creates content of zip type" do
        described_class.new(stub_uploaded_files, user).call
        expect(Attachment.last.file.blob.content_type).to eq("application/zip")
      end

      it "returns Hash containing filename, file_password and file_url" do
        expect(described_class.new(stub_uploaded_files, user).call).to include(:filename, :file_password, :file_url)
      end

      it "returns filename of specified length and .zip extension" do
        expect(described_class.new(stub_uploaded_files, user).call[:filename]).to match(/\w{26}\.zip/) 
      end

      it "returns letters-digits password of specified length" do
        expect(described_class.new(stub_uploaded_files, user).call[:file_password]).to match(/[a-z0-9]{32}/) 
      end
    end


    def stub_uploaded_files
      pic = File.open("./spec/fixtures/files/pic_test.jpg", "rb")
      doc = File.open("./spec/fixtures/files/doc_test.txt", "rb")

      pic_tempfile = Tempfile.new(["pic_test", ".jpg"])
      doc_tempfile = Tempfile.new(["doc_test", ".txt"])

      pic_tempfile.binmode.write(pic.read)
      doc_tempfile.binmode.write(doc.read)

      pic_file = {
        tempfile: pic_tempfile,
        filename: "pic_test.jpg",
        type: "image/jpeg",
        head: "Content-Disposition: form-data; name=\"files[]\"; filename=\"pic_test.jpg\"\r\nContent-Type: image/jpeg\r\n"
      }

      doc_file = {
        tempfile: doc_tempfile,
        filename: "doc_test.txt",
        type: "text/plain",
        head: "Content-Disposition: form-data; name=\"files[]\"; filename=\"doc_test.txt\"\r\nContent-Type: text/plain\r\n"
      }

      pic_uploaded_file = ActionDispatch::Http::UploadedFile.new(pic_file)
      doc_uploaded_file = ActionDispatch::Http::UploadedFile.new(doc_file)

      { files: [ pic_uploaded_file, doc_uploaded_file ] }
    end
  end
end
