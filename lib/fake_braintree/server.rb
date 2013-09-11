require 'capybara'
require 'capybara/server'
# require 'rack/handler/thin'
require 'rack/handler/webrick'

class FakeBraintree::Server
  def boot
    with_webrick_runner do
      server = Capybara::Server.new(FakeBraintree::SinatraApp)
      server.boot
      ENV['GATEWAY_PORT'] = server.port.to_s
    end
  end

  private

  # TODO: reduce code duplication,.
  def with_webrick_runner
    default_server_process = Capybara.server
    Capybara.server do |app, port|
      Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new("/dev/null", 7))
    end
    yield
  ensure
    Capybara.server(&default_server_process)
  end
  
  
  # Disabling thin support due to problems when running in tandem with
  # capybara-webkit or poltergeist. Thin's threading throws Capybara into a loop.
  #
  # See here: 
  # def with_thin_runner
  #   default_server_process = Capybara.server
  #   Capybara.server do |app, port|
  #     Rack::Handler::Thin.run(app, Port: port)
  #   end
  #   yield
  # ensure
  #  Capybara.server(&default_server_process)
  # end
end
