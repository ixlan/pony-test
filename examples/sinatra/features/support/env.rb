# Sets up the Rails environment for Cucumber
ENV["RACK_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../app.rb')

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

require 'rack/test'
require 'webrat'
require 'cucumber/webrat/table_locator' # Lets you do table.diff!(table_at('#my_table').to_a)

Webrat.configure do |config|
  config.mode = :rack
end

require File.expand_path(File.dirname(__FILE__) + '../../../../../lib/email_spec')

class AppWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  def app
    Sinatra::Application.new
  end
end

World { AppWorld.new }
