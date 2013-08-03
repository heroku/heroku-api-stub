# Heroku API Stub

## Run Standalone

    bundle install
    bundle exec bin/heroku-api-stub
    curl -i -H "Accept: application/vnd.heroku+json; version=3" --user :anything http://localhost:4000/apps/anything

## In Project

``` ruby
source "https://rubygems.org"

group :development do
  gem "heroku_api_stub"
end
```

```
heroku_api_stub: bundle exec heroku_api_stub --port $PORT
```

## In Tests

``` ruby
source "https://rubygems.org"

group :test do
  gem "excon"
  gem "heroku_api_stub"
  gem "rspec" # only required for this example
  gem "webmock"
end
```

``` ruby
describe "Stub Example" do
  before do
    HerokuAPIStub.initialize
    @api = Excon.new(
      "https://:fake-access-token@api.heroku.com",
      headers: {
        "Accept" => "application/vnd.heroku+json; version=3",
      })
  end

  it "connects" do
    @api.get(path: "/apps/anything", expects: 200)
  end
end
```

``` ruby
  it "handles an error" do
    HerokuAPIStub.initialize do
      get "apps/:id" do
        404
      end
    end
  end
```

## Deploy to Platform

```
heroku create
git push heroku master
```
