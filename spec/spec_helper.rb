RSpec.configure do |config|
  config.filter_run_when_matching :focus

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
end
