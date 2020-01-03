require "minitest/autorun"
require "sql-builder"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

class ActiveSupport::TestCase
  def assert_sql_equal(excepted, sql)
    assert_equal excepted.strip.gsub(/[\s]+/, " "), sql.strip.gsub(/[\s]+/, " ")
  end
end