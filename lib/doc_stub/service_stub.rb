module DocStub
  class ServiceStub < Sinatra::Base
    use Rack::Instruments

    before do
      @body = MultiJson.decode(request.body.read) rescue {}
    end

    private

    def require_params!(keys)
      missing = []
      keys.each do |k|
        missing << k unless @body[k]
      end
      halt(400, MultiJson.encode(
        message: "Require params: #{missing.join(', ')}."
      )) if missing.size > 0
    end

    def validate_params!(keys)
      extra = @body.keys - keys
      halt(400, MultiJson.encode(
        message: "Unknown params: #{extra.join(', ')}."
      )) if extra.size > 0
    end
  end
end
