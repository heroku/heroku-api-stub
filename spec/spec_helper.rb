ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "minitest/spec"
require "rack/test"

require_relative "../lib/heroku_api_stub"
