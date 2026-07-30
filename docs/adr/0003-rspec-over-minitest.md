# Use RSpec instead of Rails' default Minitest

Rails generates new apps with Minitest configured and ready to go — zero setup cost, which matters under a tight time limit. We chose to add RSpec instead, a deliberate deviation from the framework default.

The trade-off was made explicitly for spec readability and extendability going forward, at the cost of the Gemfile/bundle time RSpec requires that Minitest wouldn't have. A future reader seeing RSpec in an otherwise vanilla Rails 8 app should read this as an intentional choice, not a leftover from a different starting template.
