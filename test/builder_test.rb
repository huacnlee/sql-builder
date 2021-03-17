# frozen_string_literal: true

require "test_helper"

class BuilderTest < ActiveSupport::TestCase
  test "complex" do
    query = SQLBuilder.new("SELECT cb.*, acc.member_id FROM psql.cashbalance cb LEFT JOIN public.accounts as acc on acc.origin_id = cb.acc_no")
      .where("cb.acc_no = ?", 1014382)
      .where("cb.currency = ?", "SGD")
      .where("cb.dt <= ?", "20200102")
      .where("cb.dt not in (?)", ["20200101", "20191201"])
      .order("acc.member_id asc")
      .order("cb.dt desc")
      .limit(10).offset(2)

    expected = <<~SQL
      SELECT cb.*, acc.member_id
      FROM psql.cashbalance cb
      LEFT JOIN public.accounts as acc on acc.origin_id = cb.acc_no
      WHERE cb.acc_no = 1014382 AND cb.currency = 'SGD' AND cb.dt <= '20200102' AND cb.dt not in ('20200101','20191201')
      ORDER BY acc.member_id asc, cb.dt desc
      LIMIT 10
      OFFSET 2
    SQL

    assert_sql_equal expected, query.to_sql

    # where by query instance
    count_query = SQLBuilder.new("select count(*) from psql.cashbalance")
      .where(query)
    expected = "select count(*) from psql.cashbalance WHERE cb.acc_no = 1014382 AND cb.currency = 'SGD' AND cb.dt <= '20200102' AND cb.dt not in ('20200101','20191201')"
    assert_equal expected, count_query.to_sql
  end

  test "where" do
    expected = "select * from users WHERE name = 'hello world' AND status != 1"
    assert_sql_equal expected, SQLBuilder.new("select * from users").where("name = ?", "hello world").where("status != ?", 1).to_sql
  end

  test "where with hash options" do
    expected = "select * from users WHERE age = 100 AND name = 'hello world' AND status = 1"
    scope = SQLBuilder.new("select * from users")
      .where("age = :age", age: 100)
      .where(name: "hello world", status: 1)
    assert_sql_equal expected, scope.to_sql
  end

  test "group" do
    expected = "select name from users WHERE gender = 1 GROUP BY name, gender LIMIT 10 OFFSET 2"
    assert_equal expected, SQLBuilder.new("select name from users").where("gender = ?", 1).group("name").group("gender").limit(10).offset(2).to_sql
    assert_equal expected, SQLBuilder.new("select name from users").where("gender = ?", 1).group("name", "gender").limit(10).offset(2).to_sql
    assert_equal expected, SQLBuilder.new("select name from users").where("gender = ?", 1).group("name, gender").limit(10).offset(2).to_sql
    assert_equal expected, SQLBuilder.new("select name from users").where("gender = ?", 1).group([:name, :gender]).limit(10).offset(2).to_sql
    assert_equal expected, SQLBuilder.new("select name from users").where("gender = ?", 1).group(:name, :gender).limit(10).offset(2).to_sql

    # should unique
    out = SQLBuilder.new("select name from users").where("gender = ?", 1)
      .group(:name, :gender)
      .group([:name, :gender])
      .group("name", "gender")
      .group("name").group("gender")
      .limit(10).offset(2).to_sql
    assert_equal expected, out
  end

  test "having" do
    expected = "select name from users WHERE gender = 1 GROUP BY name HAVING gender != 2 AND age = 18 LIMIT 10 OFFSET 2"
    assert_equal expected, SQLBuilder.new("select name from users").where("gender = ?", 1).group("name").having("gender != ?", 2).having(age: 18).limit(10).offset(2).to_sql
    assert_equal expected, SQLBuilder.new("select name from users").where("gender = ?", 1).group("name").having("gender != 2").having("age = 18").limit(10).offset(2).to_sql
  end

  test "pagination" do
    expected = "select * from users WHERE age != 20 LIMIT 20 OFFSET 0"
    assert_equal expected, SQLBuilder.new("select * from users").where("age != ?", 20).page(1).per(20).to_sql
    assert_equal expected, SQLBuilder.new("select * from users").where("age != ?", 20).per(20).page(1).to_sql

    assert_equal "select * from users WHERE age != 20 LIMIT 12 OFFSET 12", SQLBuilder.new("select * from users").where("age != ?", 20).per(12).page(2).to_sql
    assert_equal "select * from users WHERE age != 20 LIMIT 12 OFFSET 24", SQLBuilder.new("select * from users").where("age != ?", 20).per(12).page(3).to_sql
  end

  test "or" do
    expected = "select * from users WHERE age = 20 AND num = 10 OR desc = 'test' AND color = 'green' OR gender = 1 AND name = 'hello world'"
    assert_equal expected, SQLBuilder.new("select * from users").where("age = ?", 20).where(num: 10).or(SQLBuilder.new.where("gender = ?", 1).where(name: "hello world").or(SQLBuilder.new.where(desc: "test", color: "green"))).to_sql
    assert_equal expected, SQLBuilder.new("select * from users").where("age = ?", 20).where(num: 10).or(SQLBuilder.new.where(desc: "test", color: "green")).or(SQLBuilder.new.where("gender = ?", 1).where(name: "hello world")).to_sql
  end
end
