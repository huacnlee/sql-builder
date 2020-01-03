0.1.0
---------

- First release.

query = SQLBuilder.new("SELECT * FROM users").where("name = ?", "hello world").where("status != ?", 1).order("created_at desc").order("id asc").page(1).per(20)