require_relative "../spec_helper"

describe HerokuAPIStub::ServiceStub do
  include Rack::Test::Methods

  class TestApp < HerokuAPIStub::ServiceStub
    get "/" do
      200
    end

    post "/require" do
      require_params!(["key"])
      200
    end

    post "/require-nested" do
      require_params!(["key1:key2"])
      200
    end

    post "/validate" do
      validate_params!(["key"])
      200
    end

    post "/validate-nested" do
      validate_params!(["key1:key2"])
      200
    end
  end

  def app
    TestApp
  end

  before do
    header "Accept", "application/vnd.heroku+json; version=3"
    header "Authorization", "Bearer fake-access-token"
  end

  describe "authorization" do
    it "responds to basic authorization" do
      header "Authorization", "Bearer fake-access-token"
      get "/"
      assert_equal 200, last_response.status
    end

    it "responds to bearer token authorization" do
      header "Authorization", "Bearer fake-access-token"
      get "/"
      assert_equal 200, last_response.status
    end

    it "401s if unauthorized" do
      header "Authorization", ""
      get "/"
      assert_equal 401, last_response.status
    end
  end

  describe "versioning" do
    it "responds to V3" do
      header "Accept", "application/vnd.heroku+json; version=3"
      get "/"
      assert_equal 200, last_response.status
    end

    it "404s on other versions" do
      header "Accept", "application/vnd.heroku+json; version=2"
      get "/"
      assert_equal 404, last_response.status
    end
  end

  describe "parameter requirement" do
    before do
      header "Content-Type", "application/json"
    end

    it "recognizes a required key" do
      post "/require", MultiJson.encode({
        key: "val"
      })
      assert_equal 200, last_response.status
    end

    it "recognizes a nested required key" do
      post "/require-nested", MultiJson.encode({
        key1: { key2: "val" }
      })
      assert_equal 200, last_response.status
    end

    it "requires a key" do
      post "/require", "{}"
      assert_equal 400, last_response.status
      assert_equal({
        "id" => "invalid_params",
        "message" => "Require params: key."
      }, MultiJson.decode(last_response.body))
    end

    it "requires a nested key" do
      post "/require-nested", "{}"
      assert_equal 400, last_response.status
      assert_equal({
        "id" => "invalid_params",
        "message" => "Require params: key1:key2."
      }, MultiJson.decode(last_response.body))
    end
  end

  describe "validation requirement" do
    before do
      header "Content-Type", "application/json"
    end

    it "recognizes a valid key" do
      post "/validate", MultiJson.encode({
        key: "val"
      })
      assert_equal 200, last_response.status
    end

    it "recognizes a nested valid key" do
      post "/validate-nested", MultiJson.encode({
        key1: { key2: "val" }
      })
      assert_equal 200, last_response.status
    end

    it "detects an invalid key" do
      post "/validate", MultiJson.encode({
        other: "val"
      })
      assert_equal 400, last_response.status
      assert_equal({
        "id" => "invalid_params",
        "message" => "Unknown params: other."
      }, MultiJson.decode(last_response.body))
    end

    it "requires a nested key" do
      post "/validate-nested", MultiJson.encode({
        key1: { other: "val" }
      })
      assert_equal 400, last_response.status
      assert_equal({
        "id" => "invalid_params",
        "message" => "Unknown params: key1:other."
      }, MultiJson.decode(last_response.body))
    end
  end
end
