module HerokuAPIStub
  class Generator
    def initialize(doc)
      @doc = doc
    end

    def run
      @app = Sinatra.new(ServiceStub)
      @doc["resources"].each do |_, resource|
        example = {}
        resource["attributes"].each do |name, info|
          next if !info["serialized"]
          example[name] = info["example"]
        end
        example = MultiJson.encode(example, pretty: true)
        resource["actions"].each do |_, action|
          method = action["method"]
          path   = action["path"]
          status = action["statuses"][0]
          required_params =
            action["attributes"] && action["attributes"]["required"]
          optional_params =
            action["attributes"] && action["attributes"]["optional"]
          if required_params && !optional_params
            optional_params = required_params
          end
          # "{app}" to ":app"
          path.gsub!(/{([a-z_]*)}/, ':\1')
          #puts "method=#{method} path=#{path}"
          @app.send(method.downcase, path) do
            require_params!(required_params) if required_params
            validate_params!(optional_params) if optional_params
            [status, example]
          end
        end
      end
      @app
    end
  end
end
