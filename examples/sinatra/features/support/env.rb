ENV["RACK_ENV"] ||= "test"

require File.join(File.dirname(__FILE__), %w{ .. .. app })
require File.join(File.dirname(__FILE__), %w{ .. .. .. .. lib pony-test })

require 'rack/test'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rack
end

World do
  def app
    Sinatra::Application.new
  end

  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  include Pony::TestHelpers
end
