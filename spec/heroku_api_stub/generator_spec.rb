require_relative "../spec_helper"

describe HerokuAPIStub::Generator do
  include Rack::Test::Methods

  App = HerokuAPIStub::Generator.new.run

  def app
    App
  end

  before do
    header "Accept", "application/vnd.heroku+json; version=3"
    header "Authorization", "Bearer fake-access-token"
  end

  it "correctly serializes an app" do
    get "/apps/anything"
    assert_equal 200, last_response.status
    assert_equal serialized_app, MultiJson.decode(last_response.body)
  end

  it "correctly serializes an app list" do
    get "/apps"
    assert_equal 200, last_response.status
    assert_equal [serialized_app], MultiJson.decode(last_response.body)
  end

  private

  def serialized_app
    {
      "archived_at" => "2012-01-01T12:00:00-00:00",
      "buildpack_provided_description" => "Ruby/Rack",
      "created_at" => "2012-01-01T12:00:00-00:00",
      "git_url" => "git@heroku.com/example.git",
      "id" => "01234567-89ab-cdef-0123-456789abcdef",
      "maintenance" => false,
      "name" => "example",
      "owner" => {
        "email" => "username@example.com",
        "id" => "01234567-89ab-cdef-0123-456789abcdef"
      },
      "region" => {
        "id" => "01234567-89ab-cdef-0123-456789abcdef",
        "name" => "us"
      },
      "released_at" => "2012-01-01T12:00:00-00:00",
      "repo_size" => 1024,
      "slug_size" => 512,
      "stack" => "cedar",
      "updated_at" => "2012-01-01T12:00:00-00:00",
      "web_url" => "http://example.herokuapp.com"
    }
  end
end
