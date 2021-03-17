$:.push File.expand_path("../lib", __FILE__)
require "sql-builder/version"

Gem::Specification.new do |s|
  s.name = "sql-builder"
  s.version = SQLBuilder::VERSION
  s.authors = ["Jason Lee"]
  s.email = ["huacnlee@gmail.com"]

  s.required_ruby_version = ">= 2.3.0"

  s.summary = "A simple SQL builder for generate SQL for non-ActiveRecord supports databases"
  s.description = "A simple SQL builder for generate SQL for non-ActiveRecord supports databases."
  s.homepage = "https://github.com/huacnlee/sql-builder"
  s.license = "MIT"

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["changelog_uri"] = "https://github.com/huacnlee/sql-builder/blob/master/CHANGELOG.md"

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 4.2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
end
