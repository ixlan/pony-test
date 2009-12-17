unless defined?(Pony) or defined?(ActionMailer)
  Kernel.warn("Either Pony or ActionMailer need to be loaded for email-spec to function.")
end

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'email_spec/background_processes'
require 'email_spec/deliveries'
require 'email_spec/address_converter'
require 'email_spec/helpers'
require 'email_spec/matchers'
