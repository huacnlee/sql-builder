$:.push File.expand_path("../lib", __FILE__)
require "sql-builder/version"

Gem::Specification.new do |s|
  s.name          = "sql-builder"
  s.version       = SQLBuilder::VERSION
  s.authors       = ["Jason Lee"]
  s.email         = ["huacnlee@gmail.com"]

  s.summary       = "A simple SQL builder for generate SQL for non-ActiveRecord supports databases"
  s.description   = "A simple SQL builder for generate SQL for non-ActiveRecord supports databases."
  s.homepage      = "https://github.com/huacnlee/sql-builder"
  s.license       = "MIT"

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["changelog_uri"] = "https://github.com/huacnlee/sql-builder/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "activerecord", ">= 4.2"
end
