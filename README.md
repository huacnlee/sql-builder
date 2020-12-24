# SQLBuilder

A simple SQL builder for generate SQL for non-ActiveRecord supports databases.

[![build](https://github.com/huacnlee/sql-builder/workflows/build/badge.svg)](https://github.com/huacnlee/sql-builder/actions?query=workflow%3Abuild)

[中文说明](https://ruby-china.org/topics/39399)

## Features

- ActiveRecord style DSL.
- [Sanitize](https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql) SQL by ActiveRecord methods, keep security.
- Support any SQL databases (MySQL, PostgreSQL, TiDB, Amazon Redshift...)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sql-builder'
```

## Usage

More API documents, please visit [rdoc.info/gems/sql-builder](https://rdoc.info/gems/sql-builder).

```ruby
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

### More complex case

```ruby
query = SQLBuilder.new("SELECT users.name, users.age, user_profiles.bio, user_profiles.avatar FROM users INNER JOIN user_profiles ON users.id = user_profiles.user_id")
```

Add the conditions by request params:

```ruby
query.where("age >= ?", params[:age]) unless params[:age].blank?
query.where(status: params[:status]) unless params[:status].nil?
if params[:created_at_from] && params[:created_at_to]
  query.where("created_at >= ? and created_at <= ?", params[:created_at_from], params[:created_at_to])
end
query.order("id desc").limit(100).to_sql
```

Returns string SQL:

```sql
SELECT users.name, users.age, user_profiles.bio, user_profiles.avatar FROM users
INNER JOIN user_profiles ON users.id = user_profiles.user_id
WHERE age >= 18 AND status = 3 AND created_at >= '2020-01-03 10:54:08 +0800' AND created_at <= '2020-01-03 10:54:08 +0800'
ORDER BY id desc LIMIT 100 OFFSET 0
```

### Group by, Having

```rb
query = SQLBuilder.new("select user_id, name, count(ip) as ip_count from user_visits")
query.where(status: 1).where("created_at > ?", params[:created_at])
query.group("user_id").group("name").having("count(ip) > 2")
query.to_sql
```

returns

```sql
select user_id, name, count(ip) as ip_count from user_visits WHERE status = 1 AND status = 1 AND created_at > '2020-01-03 10:54:08 +0800' GROUP BY user_id, name HAVING count(ip) > 2"
```

## TODO

- [ ] `OR` conditions;
- [x] `Group By`, `Having`;

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
