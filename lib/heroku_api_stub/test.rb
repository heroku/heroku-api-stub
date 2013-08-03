require "webmock"

include WebMock::API

module HerokuAPIStub
  Stub = HerokuAPIStub::Generator.new.run

  def self.initialize(&block)
    url = ENV["HEROKU_API_URL"] || "https://api.heroku.com"
    stub_service(url, Stub, &block)
  end

  private

  def self.stub_service(uri, stub, &block)
    uri = URI.parse(uri)
    port = uri.port != uri.default_port ? ":#{uri.port}" : ""
    stub = block ? Sinatra.new(stub, &block) : stub
    stub_request(:any, /^#{uri.scheme}:\/\/(.*:.*@)?#{uri.host}#{port}\/.*$/).
      to_rack(stub)
  end
end
