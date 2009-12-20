require 'uri'

unless defined?(Pony)
  Kernel.warn("Pony needs to be loaded for email-spec to function.")
end

module EmailSpec

  if defined?(Pony)
    #reopen Pony module and replace mail method
    module ::Pony
      def self.deliveries
        @deliveries ||= []
      end

      def self.mail(options)
        email = build_tmail(options)
        deliveries << email
        EmailSpec::Helpers.current_email = email
      end
    end
  end

  module Helpers
    if defined?(Pony)
      def mailer; Pony; end
    else
      #no mail sender available
      def mailer; raise("email_spec requires Pony"); end
    end

    # current_email is the last email either sent or opened
    attr_accessor :current_email
    attr_accessor :current_email_address

    def all_emails
      mailer.deliveries
    end

    def last_email_sent
      self.current_email = mailer.deliveries.last || raise("No email has been sent!")
    end

    def reset_mailer
      mailer.deliveries.clear
      current_email_address = nil
      current_email = nil
    end

    def inbox_for(address = current_email_address)
      # Deal with pronouns from cucumber steps
      # I/they as the address means use the same address as last time
      unless address.nil? || address.empty? || address == "I" || address == "they"
        self.current_email_address = address
      end

      #current_email_address should either be nil or have a specific address
      if self.current_email_address.nil?
        mailer.deliveries
      else
        mailer.deliveries.select { |m| m.to.include?(address) || (m.bcc && m.bcc.include?(address)) || (m.cc && m.cc.include?(address)) }
      end
    end
    alias_method :inbox, :inbox_for

    def open_email_for(address = current_email_address, opts={})
      self.current_email = find_email(address, opts).first
    end
    alias_method :open_email, :open_email_for

    def find_email_for(address = current_email_address, opts={})
      email = inbox_for(address)

      if opts[:with_subject]
        email = email.select { |m| m.subject =~ Regexp.new(opts[:with_subject]) }
      end

      if opts[:with_text]
        email = email.select { |m| m.body =~ Regexp.new(opts[:with_text]) }
      end

      if email.empty?
        error = "#{opts.keys.first.to_s unless opts.empty?} #{('"' + opts.values.first.to_s + '"') unless opts.empty?}"
        raise Spec::Expectations::ExpectationNotMetError, "Could not find email #{error}. \n Found the following emails:\n\n #{all_emails.to_s}"
      end
    end
    alias_method :find_email, :find_email_for

    def email_links(email = current_email)
      links = URI.extract(email.body, ['http', 'https'])
      raise "No links found in #{email.body}" if links.nil? || links.empty?
      links
    end

    def email_links_matching(pattern, email = current_email)
      pattern = /#{Regexp.escape(pattern)}/ unless pattern.is_a?(Regexp)
      links = email_links(email).select { |link| link =~ pattern }
      raise "No link found matching #{pattern.inspect} in #{email.body}" if links.nil? || links.empty?
      links
    end

    private

    def parse_email_count(amount)
      case amount
      when "no"
        0
      when "an"
        1
      else
        amount.to_i
      end
    end
  end
end
