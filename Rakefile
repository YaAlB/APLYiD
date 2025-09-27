require 'json'
require 'rake'

task default: [:run]

desc 'Calculate total cost of notifications'
task :run do
  $LOAD_PATH.unshift(File.dirname(__FILE__), 'lib')
  require 'notification_app'

  notification_prices_json = File.read('data/notification_prices.json')
  notification_logs_json   = File.read('data/notification_logs.json')

  summaries = NotificationApp.call(notification_prices_json, notification_logs_json)

  puts 'Company           Count    Cost'
  puts '--------------------------------'
  summaries.each do |summary|
    puts format(
      "%<company>-18s%<count>-9d$%<cost>6.2f",
      company: summary['company'],
      count:   summary['notification_count'],
      cost:    summary['cost']
    )
  end
end
