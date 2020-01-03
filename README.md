# SQLBuilder

A simple SQL builder for generate SQL for non-ActiveRecord supports databases.

[![Build Status](https://travis-ci.org/huacnlee/sql-builder.svg?branch=master)](https://travis-ci.org/huacnlee/sql-builder)

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
SQLBuilder.new("SELECT * FROM users")
  .where("name = ?", "hello world")
  .where("status != ?", 1)
  .order("created_at desc")
  .order("id asc")
  .page(1)
  .per(20)
  .to_sql

=> "SELECT * FROM users WHERE name = 'hello world' AND status != 1 ORDER BY created_at desc, id asc LIMIT 20 OFFSET 0"
```

More complext:

```rb
query = SQLBuilder.new("SELECT users.name, users.age, user_profiles.bio, user_profiles.avatar FROM users INNER JOIN user_profiles ON users.id = user_profiles.user_id")

# conditions by params
query.where("age >= ?", params[:age]) unless params[:age].blank?
query.where("status = ?", params[:status]) unless params[:status].nil?
if params[:created_at_from] && params[:created_at_to]
  query.where("created_at >= ? and created_at <= ?", params[:created_at_from], params[:created_at_to])
end
query.order("id desc").limit(100).to_sql

=> "SELECT users.name, users.age, user_profiles.bio, user_profiles.avatar FROM users INNER JOIN user_profiles ON users.id = user_profiles.user_id WHERE age >= 18 AND status = 3 AND created_at >= '2020-01-03 10:54:08 +0800' and created_at <= '2020-01-03 10:54:08 +0800' ORDER BY id desc LIMIT 100 OFFSET 0"
```

## TODO

- [ ] where by or;

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
