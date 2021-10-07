begin
  require 'rack'
rescue NameError
  raise NameError, 'IsItWorking::Handler::BasicAuth requires rack, please add it to your Gemfile.'
end

module IsItWorking
  class Handler
    # A middleware to implement a basic authentication flow before providing access to is_it_working endpoints
    class BasicAuth
      def initialize(app=nil, route_path=IsItWorking::HANDLER_PATH, &block)
        @app = app
        @handler = ::IsItWorking::Handler.new(app, route_path, &block)
        @route_path = route_path
      end

      def call(env)
        if @app.nil? || env['PATH_INFO'] == @route_path
          auth = Rack::Auth::Basic.new(@handler) do |u, p|
            u == username && p == password
          end
          auth.call(env)
        else
          @app.call(env)
        end
      end

      private

      def username
        ENV['IS_IT_WORKING_USERNAME']
      end

      def password
        ENV['IS_IT_WORKING_PASSWORD']
      end
    end
  end
end
