# SQLBuilder write the complex SQL as DSL
#
# Example:
#
#    query = SQLBuilder.new("SELECT * FROM users inner join ")
#      .where("name = ?", "hello world")
#      .where("status != ?", 1)
#      .order("created_at desc")
#      .order("id asc")
#      .page(1).per(20)
#      .to_sql
require "active_record"

class SQLBuilder
  attr_reader :sql, :conditions, :orders, :limit_options, :page_options
  delegate :sanitize_sql, :sanitize_sql_for_order, to: ActiveRecord::Base

  def initialize(sql = "")
    @sql = sql
    @conditions = []
    @orders = []
    @limit_options = {}
    @page_options = { per_page: 20 }
  end

  # Add `AND` condition
  #
  # query.where("name = ?", params[:name]).where("age >= ?", 18)
  # or
  # count_query.where(query)
  def where(*condition)
    case condition.first
    when SQLBuilder
      query_scope = condition.first
      @conditions = query_scope.conditions
    else
      conditions << sanitize_sql(condition)
    end

    self
  end

  # Order By
  #
  # query.order("name asc").order("created_at desc").to_sql
  # => "ORDER BY name asc, created_at desc"
  def order(condition)
    orders << sanitize_sql_for_order(condition)
    self
  end

  # Offset
  #
  # query.offset(3).limit(10) => "LIMIT 10 OFFSET 3"
  def offset(offset)
    limit_options[:offset] = offset.to_i
    self
  end

  # Limit
  #
  # query.offset(3).limit(10) => "LIMIT 10 OFFSET 3"
  def limit(limit)
    limit_options[:offset] ||= 0
    limit_options[:limit] = limit.to_i
    self
  end

  # Pagination
  #
  # query.page(1).per(12) => "LIMIT 12 OFFSET 0"
  # query.page(2).per(12) => "LIMIT 12 OFFSET 12"
  def page(page_no)
    page_options[:page] = page_no
    page_options[:per_page] ||= 10

    limit_options[:offset] = page_options[:per_page].to_i * (page_options[:page].to_i - 1)
    limit_options[:limit] = page_options[:per_page].to_i
    self
  end

  # See page
  def per(per_page)
    page_options[:per_page] = per_page
    self.page(page_options[:page])
    self
  end

  # Generate SQL
  def to_sql
    sql_parts = [sql]
    if conditions.any?
      sql_parts << "WHERE " + conditions.join(" AND ")
    end
    if orders.any?
      sql_parts << "ORDER BY " + orders.join(", ")
    end
    if limit_options[:limit]
      sql_parts << "LIMIT " + limit_options[:limit].to_s
    end
    if limit_options[:limit] && limit_options[:offset]
      sql_parts << "OFFSET " + limit_options[:offset].to_s
    end
    sql_parts.join(" ")
  end
end
