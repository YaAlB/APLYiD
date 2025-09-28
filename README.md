# APLYiD Technical Test - Development Guide

## Getting Started

### Prerequisites
- Ruby 3.1.2 or higher
- Bundler gem

### Setup
```bash
# Install dependencies
bundle install

# Run the application
bundle exec rake

# Run tests
bundle exec rspec
```

## Code Organisation

### Domain Models

#### Notification
```ruby
# Create a notification
notification = Notification.new(
  company: 'Apple',
  type: 'sms',
  country: 'AU'
)

# From hash data
notification = Notification.from_hash({
  'company' => 'Apple',
  'type' => 'sms',
  'country' => 'AU'
})

# Check if notification matches criteria
notification.matches?(type: 'sms', country: 'AU') # => true
```

#### Pricing
```ruby
# Load pricing from JSON
pricing = Pricing.new(pricing_json)

# Get cost for notification
cost = pricing.cost_for(type: 'sms', country: 'AU') # => 0.50

# Get available types and countries
pricing.available_types # => ['sms', 'email']
pricing.available_countries_for('sms') # => ['AU', 'NZ', 'UK']
```

#### CompanySummary
```ruby
# Create company summary
summary = CompanySummary.new('Apple')

# Add notifications
summary.add_notification(notification1)
summary.add_notification(notification2)

# Calculate costs
summary.calculate_cost!(pricing)

# Get statistics
summary.notification_count # => 2
summary.count_by_type('sms') # => 1
summary.count_by_country('AU') # => 1

# Convert to hash for output
summary.to_hash # => { 'company' => 'Apple', 'notification_count' => 2, 'cost' => 1.0 }
```

### Main Application

#### NotificationApp
```ruby
# Simple interface for calculating costs
result = NotificationApp.call(pricing_json, logs_json)

# Result format
[
  {
    'company' => 'Apple',
    'notification_count' => 3,
    'cost' => 1.50
  },
  # ... more companies
]
```

## Testing

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/notification_spec.rb

# Run specific test
bundle exec rspec spec/notification_spec.rb:25
```