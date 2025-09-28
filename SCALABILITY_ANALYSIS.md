# Scalability Analysis

The current implementation works well for the test requirements but has several bottlenecks that would cause issues in production. Here's what I found and how to fix it.

## Key Issues

### 1. Memory Problems
Right now we load everything into memory at once:
```ruby
# This will break with large datasets
@notifications = parse_notifications(notification_logs_data)
```

**Problem**: With 1M notifications, this needs ~100MB+ RAM and will crash on larger datasets.

**Fix**: Process in batches:
```ruby
def process_in_batches(logs_data, batch_size = 1000)
  JSON.parse(logs_data).each_slice(batch_size) do |batch|
    process_batch(batch)
  end
end
```

### 2. Single-Threaded Processing
All calculations happen sequentially:
```ruby
@company_summaries.each_value do |summary|
  summary.calculate_cost!(@pricing)
end
```

**Problem**: Can't use multiple CPU cores, processing time scales linearly.

**Fix**: Parallel processing:
```ruby
require 'parallel'
Parallel.each(@company_summaries.values, in_threads: 4) do |summary|
  summary.calculate_cost!(@pricing)
end
```

### 3. No Caching
Pricing data gets parsed on every request:
```ruby
@pricing = Pricing.new(pricing_data)  # Parsed every time
```

**Problem**: Unnecessary CPU usage, slower response times.

**Fix**: Cache the pricing data:
```ruby
class Pricing
  @@cache = {}
  
  def self.cached_new(pricing_data)
    cache_key = Digest::MD5.hexdigest(pricing_data.to_s)
    @@cache[cache_key] ||= new(pricing_data)
  end
end
```

### 4. File-Based Storage
Using JSON files for data storage:
```ruby
notification_prices_json = File.read('data/notification_prices.json')
```

**Problem**: No concurrent access, becomes I/O bottleneck, no querying.

**Fix**: Use a proper database with connection pooling.

### 5. Pricing Model Limitation
The current pricing model assumes global rates, but companies often have different pricing based on their location:

```ruby
# Current: Global pricing only
pricing.cost_for(type: 'sms', country: 'AU')  # Same for all companies
```

**Problem**: Real companies have different rates based on their country/region. A company in Australia should pay different rates than one in the UK, even for the same notification type.

**Fix**: Company-specific pricing:
```ruby
class Pricing
  def cost_for(company:, type:, country:)
    company_pricing = get_company_pricing(company)
    company_pricing.cost_for(type: type, country: country)
  end
end
```
