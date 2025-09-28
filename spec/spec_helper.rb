# frozen_string_literal: true

require 'rspec'
require 'json'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'notification'
require 'pricing'
require 'company_summary'
require 'cost_calculator'
require 'notification_app'

RSpec.configure do |config|
  config.default_formatter = 'doc'
  config.order = :random
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
end


