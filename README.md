# APLYiD Technical Test

When a customer of one our clients/companies finishes an action we send notifications via SMS and Email to that company. For example, "John Doe" which is a client of Company "Apple" finishes a biometric verification, so we send a notification to company "Apple" that John Doe finished his verification.

Each notification has a different cost depending on which country it’s sent to (NZ, AU or UK).

We keep the logs when a notification is sent to a company available in `data/notification_logs.json` file.

We need to track how much each company spends on notifications so we can bill them.

## Requirements

1. Calculate for each company: total cost = ∑( per-notification cost for that type & country )
2. Print (via Rake) a human-readable table:

Company           Count    Cost
--------------------------------
Sharesies         4        $X
Mighty Ape        3        $Y
TradeMe           4        $Z

3. Write readable specs

## How to get started
1. Unzip and unpack the file in your project directory
2. Install Ruby & Bundler, then run:
```
bundle install

```
Available commands:
```
bundle exec rake → runs your app and prints the table

bundle exec rspec → runs the specs
```


## Submission
1. Push all of your finished code to the default branch of your repo (e.g. main or master).
2. From the root of your project folder, create a tarball named with your own name:
```
tar -czvf YourFirstName_YourLastName.tar.gz .
```
3. Reply to the original assignment email (or send directly to your contact) with that archive attached.

## Important Notes

**Modelling**
Break responsibilities into clear classes/modules.

No single God-class that parses everything.

**Naming**
Classes, methods, and variables should be descriptive and consistent.

**Production Quality**
Consistency in style and formatting.

**Testing**
Add unit and edge-case tests where you see value.

**Error Handling**
Guard against potential errors