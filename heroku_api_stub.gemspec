Gem::Specification.new do |gem|
  gem.name        = "heroku_api_stub"
  gem.version     = "0.1.6"

  gem.author      = "Brandur"
  gem.description = <<-eos
Service stub for the Heroku API.

Will respond to all public endpoints of the Heroku API with a sample serialized
response representing what data that endpoint would normal return. Useful in
development and testing situations where real API calls might result in state
change of real data.
  eos
  gem.email       = "brandur@mutelight.org"
  gem.homepage    = "https://github.com/heroku/heroku-api-stub"
  gem.license     = "MIT"
  gem.summary     = "Service stub for the Heroku API."

  gem.executables = ["heroku-api-stub"]
  gem.files       = ["./data/doc.json"] + Dir["./lib/**/*.rb"]

  gem.add_dependency "multi_json",       "> 0.0"
  gem.add_dependency "sinatra",          "> 0.0"
end
