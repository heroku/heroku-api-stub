# Heroku API Stub

## Run Standalone

The Heroku API stub can be run from within its own project:

    bundle install
    bundle exec bin/heroku-api-stub
    curl -i -H "Accept: application/vnd.heroku+json; version=3" --user :anything http://localhost:4000/apps/anything

## In Project

It can also be added to another project to help facilitate sane interactions
during development. Add this to your `Gemfile`:

``` ruby
source "https://rubygems.org"

group :development do
  gem "heroku_api_stub"
end
```

Now the stub can be booted from within a `Procfile`:

```
heroku_api_stub: bundle exec heroku_api_stub --port $PORT
```

## In Tests

The API mock is fully usable in a testing environment, and bundles testing helpers that use [Webmock](https://github.com/bblimke/webmock). Add something like the following to your `Gemfile`:

``` ruby
source "https://rubygems.org"

group :test do
  gem "excon"            # only required for this example
  gem "heroku_api_stub", require: ["heroku_api_stub", "heroku_api_stub/test"]
  gem "rspec"            # only required for this example
  gem "webmock"
end
```

A simple usage example from within a test might look something like this:

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

The stub's default routes can also be easily overridden to test your code
against error conditions or other special casing. The following test will fail:

``` ruby
  it "handles an error" do
    HerokuAPIStub.initialize do
      get "/apps/:id" do
        404
      end
    end
    # this will fail
    @api.get(path: "/apps/anything", expects: 404)
  end
```

## Deploy to Platform

The stub is also easily deployable against a platform like Heroku. It's also
possible to just use ours at https://api-stub.heroku.com.

```
heroku create
git push heroku master
```
