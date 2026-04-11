require 'rspec'
require 'rspec/its'
require 'pathname'
require 'fileutils'
require 'yaml'

# Add lib to load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Now require the main app code
require 'rest_runner'

# Support code for tests
Dir[File.join(__dir__, 'support', '**/*.rb')].sort.each { |f| require f }

# Configure RSpec
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Default test order is random
  config.order = :random

  # Create temporary directories for tests
  config.before(:suite) do
    FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
  end

  # Shared context for file fixtures
  config.include FileHelpers

  # Print the 10 slowest examples at the end of the test run
  config.profile_examples = 10
end
