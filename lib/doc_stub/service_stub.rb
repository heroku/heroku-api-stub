module DocStub
  class ServiceStub < Sinatra::Base
    use Rack::Instruments

    before do
      @body = MultiJson.decode(request.body.read) rescue {}
      if !request.env["HTTP_AUTHORIZATION"] ||
        !(request.env["HTTP_AUTHORIZATION"] =~ /\A(Basic|Bearer)\s+(.*)/)
        halt(401, MultiJson.encode(
          id:      "unauthorized",
          message: "Access denied."
        ))
      end
    end

    private

    def require_params!(keys)
      missing = []
      keys.each do |k|
        missing << k unless @body[k]
      end
      halt(400, MultiJson.encode(
        id:      "invalid_params",
        message: "Require params: #{missing.join(', ')}."
      )) if missing.size > 0
    end

    def validate_params!(keys)
      extra = @body.keys - keys
      halt(400, MultiJson.encode(
        id:      "invalid_params",
        message: "Unknown params: #{extra.join(', ')}."
      )) if extra.size > 0
    end
  end
end
