require "capybara/rspec"
require "json"
require "pry"
require_relative "../support/helpers.rb"
require_relative "./support/endpoint_server.rb"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

Capybara.default_driver = :selenium

def run_endpoint
  EndpointServer.run!
end
