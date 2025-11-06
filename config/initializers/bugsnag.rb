Bugsnag.configure do |config|
  config.api_key = ENV["BUGSNAG_API_KEY"]
  config.release_stage = Rails.env
  config.app_version = "1.0.0"

  config.add_on_error(proc do |report|
    report.add_metadata(:environment, { rails_env: Rails.env })
  end)
end
