# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# Configure Rails logger
Rails.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")
Rails.logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime} [#{severity}]: #{msg}\n"
end
