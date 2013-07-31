module DocStub
  class ServiceStub < Sinatra::Base
    use Rack::Instruments

    def initialize(*args, &block)
      super
    end
  end
end
