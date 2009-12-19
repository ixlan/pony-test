unless defined?(Pony)
  Kernel.warn("Pony needs to be loaded for email-spec to function.")
end

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'email_spec/deliveries'
require 'email_spec/helpers'
require 'email_spec/matchers'
