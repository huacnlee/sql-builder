# SQLBuilder

A simple SQL builder for generate SQL for non-ActiveRecord supports databases.

## Features

- Simple SQL generator with DSL.
- Sanitize SQL by ActiveRecord methods, keep security.
- Simple SQL geneate logic for keep support any SQL databases (MySQL, PostgreSQL, TiDB, Amazon Redshift...)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sql-builder'
```

## Usage

```rb
query = SQLBuilder.new("SELECT * FROM users inner join ")
  .where("name = ?", "hello world")
  .where("status != ?", 1)
  .order("created_at desc")
  .order("id asc")
  .page(1)
  .per(20)

query.to_sql
=>
```

## TODO

- [ ] where by or;

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
