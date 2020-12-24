require "active_record"

# SQLBuilder write the complex SQL as DSL
# = Example:
#
#    query = SQLBuilder.new("SELECT * FROM users")
#      .where("name = ?", "hello world")
#      .where("status != ?", 1)
#      .order("created_at desc")
#      .order("id asc")
#      .page(1).per(20)
#      .to_sql
class SQLBuilder
  attr_reader :sql, :conditions, :havings, :orders, :groups, :limit_options, :page_options

  # Create a new SQLBuilder
  #
  # == Example
  #   query = SQLBuilder.new("SELECT users.*, user_profiles.avatar FROM users INNER JOIN user_profiles ON users.id = user_profiles.id")
  #   query.to_sql
  #   # => "SELECT users.*, user_profiles.avatar FROM users INNER JOIN user_profiles ON users.id = user_profiles.id"
  #
  def initialize(sql = "")
    @sql = sql
    @conditions = []
    @orders = []
    @groups = []
    @havings = []
    @limit_options = {}
    @page_options = { per_page: 20 }
  end

  # Add `AND` condition
  #
  #   query.where("name = ?", params[:name]).where("age >= ?", 18)
  #
  # or
  #
  #   count_query.where(query)
  def where(*condition)
    case condition.first
    when SQLBuilder
      query_scope = condition.first
      @conditions = query_scope.conditions
    else
      conditions << sanitize_sql_for_assignment(condition)
    end

    self
  end

  # Order By
  #
  #   query.order("name asc").order("created_at desc").to_sql
  #   # => "ORDER BY name asc, created_at desc"
  def order(condition)
    orders << sanitize_sql_for_order(condition)
    self
  end

  # Offset
  # See #limit
  def offset(offset)
    limit_options[:offset] = offset.to_i
    self
  end

  # Limit
  #
  #   query.offset(3).limit(10).to_sql
  #   # => "LIMIT 10 OFFSET 3"
  def limit(limit)
    limit_options[:offset] ||= 0
    limit_options[:limit] = limit.to_i
    self
  end

  # Group By
  #
  # Allows to specify a group attribute:
  #
  #   query.group("name as new_name, age").to_sql
  #   # => "GROUP BY name as new_name, age"
  #
  # or
  #
  #   query.group("name", "age").to_sql # => "GROUP BY name, age"
  #   query.group(:name, :age).to_sql # => "GROUP BY name, age"
  #   query.group(["name", "age"]).to_sql # => "GROUP BY name, age"
  #   query.group("name").group("age").to_sql # => "GROUP BY name, age"
  #
  def group(*args)
    case args.first
    when Array
      @groups += args.first.collect(&:to_s)
    else
      @groups += args.collect(&:to_s)
    end

    @groups.uniq!
    self
  end

  # Having
  #
  #   query.group("name").having("count(name) > ?", 5).to_sql
  #   # => "GROUP BY name HAVING count(name) > 5"
  #
  def having(*condition)
    havings << sanitize_sql_for_assignment(condition)
    self
  end

  # Pagination
  #
  #   query.page(1).per(12).to_sql # => "LIMIT 12 OFFSET 0"
  #   query.page(2).per(12).to_sql # => "LIMIT 12 OFFSET 12"
  def page(page_no)
    page_options[:page] = page_no
    page_options[:per_page] ||= 10

    limit_options[:offset] = page_options[:per_page].to_i * (page_options[:page].to_i - 1)
    limit_options[:limit] = page_options[:per_page].to_i
    self
  end

  # Set per_page limit
  # See #page
  def per(per_page)
    page_options[:per_page] = per_page
    self.page(page_options[:page])
    self
  end

  # Generate SQL
  def to_sql
    sql_parts = [sql]
    if conditions.any?
      sql_parts << "WHERE " + conditions.flatten.join(" AND ")
    end
    if orders.any?
      sql_parts << "ORDER BY " + orders.flatten.join(", ")
    end
    if groups.any?
      sql_parts << "GROUP BY " + groups.flatten.join(", ")
    end
    if havings.any?
      sql_parts << "HAVING " + havings.flatten.join(" AND ")
    end
    if limit_options[:limit]
      sql_parts << "LIMIT " + limit_options[:limit].to_s
    end
    if limit_options[:limit] && limit_options[:offset]
      sql_parts << "OFFSET " + limit_options[:offset].to_s
    end
    sql_parts.join(" ")
  end

  private

  # https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_for_assignment
  def sanitize_sql_for_assignment(assignments)
    case assignments.first
    when Hash; sanitize_sql_hash_for_assignment(assignments.first)
    else
      sanitize_sql_array(assignments)
    end
  end

  # https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_hash_for_assignment
  def sanitize_sql_hash_for_assignment(attrs)
    attrs.map do |attr, value|
      sanitize_sql_array(["#{attr} = ?", value])
    end
  end

  def sanitize_sql_array(*args)
    ActiveRecord::Base.send(:sanitize_sql_array, *args)
  end

  def sanitize_sql_for_order(*args)
    ActiveRecord::Base.send(:sanitize_sql_for_order, *args)
  end
end
