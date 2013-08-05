module HerokuAPIStub
  class Generator
    def initialize(doc=nil)
      @doc = doc || read_default
    end

    def run
      @app = Sinatra.new(ServiceStub)
      @doc["resources"].each do |_, resource|
        example = build_example(resource)
        resource["actions"].each do |name, action|
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
            if name == "List"
              [status, MultiJson.encode([example], pretty: true)]
            else
              [status, MultiJson.encode(example, pretty: true)]
            end
          end
        end
      end
      @app
    end

    private

    def build_example(resource)
      example = {}
      resource["attributes"].each do |name, info|
        next if !info["serialized"]
        keys = name.split(":")
        hash = if (leading_keys = keys[0...-1]).size > 0
          initialize_subhashes(example, leading_keys)
        else
          example
        end
        hash[keys.last] = info["example"]
      end
      example
    end

    # returns the last subhash that was initialized
    def initialize_subhashes(hash, keys)
      key = keys.shift
      subhash = hash[key] || (hash[key] = {})
      if keys.size > 0
        initialize_subhashes(subhash, keys)
      else
        subhash
      end
    end

    def read_default
      path = File.expand_path("../../../data/doc.json", __FILE__)
      MultiJson.decode(File.read(path))
    end
  end
end
