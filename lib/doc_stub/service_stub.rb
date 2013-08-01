module DocStub
  class ServiceStub < Sinatra::Base
    use Rack::Instruments

    before do
      @body = MultiJson.decode(request.body.read) rescue {}
      @keys = materialize_keys(@body)
      if !request.env["HTTP_AUTHORIZATION"] ||
        !(request.env["HTTP_AUTHORIZATION"] =~ /\A(Basic|Bearer)\s+(.*)/)
        halt(401, MultiJson.encode(
          id:      "unauthorized",
          message: "Access denied."
        ))
      end
    end

    private

    def materialize_keys(hash, prefix="")
      keys = []
      hash.each do |k, v|
        if v.is_a?(Hash)
          keys += materialize_keys(v, "#{prefix}#{k}:")
        else
          keys << k
        end
      end
      keys
    end

    def require_params!(required)
      missing = required - @keys
      halt(400, MultiJson.encode(
        id:      "invalid_params",
        message: "Require params: #{missing.join(', ')}."
      )) if missing.size > 0
    end

    def validate_params!(optional)
      extra = @keys - optional
      halt(400, MultiJson.encode(
        id:      "invalid_params",
        message: "Unknown params: #{extra.join(', ')}."
      )) if extra.size > 0
    end
  end
end
