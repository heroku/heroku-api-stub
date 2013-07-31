module DocStub
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
          # "{app}" to ":app"
          path.gsub!(/{([a-z_]*)}/, ':\1')
          #puts "method=#{method} path=#{path}"
          @app.send(method.downcase, path) do
            [status, example]
          end
        end
      end
      @app
    end
  end
end
