require 'uri'

module EmailSpec

  if defined?(Pony)
    #reopen Pony module and replace mail method
    module ::Pony
      def self.deliveries
        @deliveries ||= []
      end

      def self.mail(options)
        deliveries << build_tmail(options)
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

    def all_emails
      mailer.deliveries
    end

    def last_email_sent
      mailer.deliveries.last || raise("No email has been sent!")
    end

    def reset_mailer
      mailer.deliveries.clear
    end

    def mailbox_for(address)
      mailer.deliveries.select { |m| m.to.include?(address) || (m.bcc && m.bcc.include?(address)) || (m.cc && m.cc.include?(address)) }
    end

    def open_email(address, opts={})
      set_current_email(find_email!(address, opts))
    end

    alias_method :open_email_for, :open_email

    def open_last_email
      set_current_email(last_email_sent)
    end

    def open_last_email_for(address)
      set_current_email(mailbox_for(address).last)
    end

    def current_email(address=nil)
      address = convert_address(address)
      email = address ? email_spec_hash[:current_emails][address] : email_spec_hash[:current_email]
      raise Spec::Expectations::ExpectationNotMetError, "Expected an open email but none was found. Did you forget to call open_email?" unless email
      email
    end

    def unread_emails_for(address)
      mailbox_for(address) - read_emails_for(address)
    end

    def read_emails_for(address)
      email_spec_hash[:read_emails][convert_address(address)] ||= []
    end

    def find_email(address, opts={})
      address = convert_address(address)
      if opts[:with_subject]
        mailbox_for(address).find { |m| m.subject =~ Regexp.new(opts[:with_subject]) }
      elsif opts[:with_text]
        mailbox_for(address).find { |m| m.body =~ Regexp.new(opts[:with_text]) }
      else
        mailbox_for(address).first
      end
    end

    #
    # Finding links
    #
    
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

    def email_spec_hash
      @email_spec_hash ||= {:read_emails => {}, :unread_emails => {}, :current_emails => {}, :current_email => nil}
    end

    def find_email!(address, opts={})
      email = find_email(address, opts)
      if email.nil?
        error = "#{opts.keys.first.to_s unless opts.empty?} #{('"' + opts.values.first.to_s + '"') unless opts.empty?}"
        raise Spec::Expectations::ExpectationNotMetError, "Could not find email #{error}. \n Found the following emails:\n\n #{all_emails.to_s}"
       end
      email
    end

    def set_current_email(email)
      return unless email
      email.to.each do |to|
        read_emails_for(to) << email
        email_spec_hash[:current_emails][to] = email
      end
      email_spec_hash[:current_email] = email
    end

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

    attr_reader :last_email_address

    def convert_address(address)
      @last_email_address = (address || current_email_address)
    end

    def mailbox_for(address)
      super(convert_address(address)) # super resides in Deliveries
    end
  end
end
