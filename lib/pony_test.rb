require 'uri'

unless defined?(Pony)
  raise("pony-test requires Pony")
end

#reopen Pony module and replace mail method
module ::Pony
  def self.mail(options)
    TestStruct.deliver(build_tmail(options))
  end

  module TestStruct
    @@deliveries = []
    @@current_email = nil
    @@current_email_address = nil

    def self.deliver(email)
      @@deliveries << email
      @@current_email = email
    end

    def deliveries
      @@deliveries
    end
    alias_method :all_emails, :deliveries

    def current_email
      @@current_email
    end

    def current_email=(email)
      @@current_email = email
    end

    def current_email_address
      @@current_email_address
    end

    def current_email_address=(address)
      @@current_email_address = address
    end

    def reset_mailer
      self.deliveries.clear
      self.current_email_address = nil
      self.current_email = nil
    end

    def last_email_sent
      self.current_email = deliveries.last
    end

    def inbox_for(address = current_email_address)
      unless address.nil? || address.empty?
        self.current_email_address = address
      end

      #current_email_address should either be nil or have a specific address
      if current_email_address.nil?
        deliveries
      else
        deliveries.select do |email| 
          (email.to && email.to.include?(address)) || 
            (email.bcc && email.bcc.include?(address)) || 
            (email.cc && email.cc.include?(address))
        end
      end
    end
    alias_method :inbox, :inbox_for

    def open_email_for(address = current_email_address, opts = {})
      self.current_email = find_email(address, opts).first
    end
    alias_method :open_email, :open_email_for

    def find_email_for(address = current_email_address, opts = {})
      puts 'address ' + address unless address.nil?
      puts opts.inspect unless opts.nil?
      email = inbox_for(address)

      if opts[:with_subject]
        email = email.select { |m| m.subject =~ Regexp.new(opts[:with_subject]) }
      end

      if opts[:with_body]
        email = email.select { |m| m.body =~ Regexp.new(opts[:with_body]) }
      end

      if email.empty?
        raise "Could not find email. \n Found the following emails:\n\n #{deliveries.to_s}"
      end

      email
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

    def translate_address(address)
      return nil if address == "I" || address == "they"
      address
    end

    def translate_email_count(amount)
      return 0 if amount == "no"
      return 1 if amount == "a" || amount == "an"
      amount.to_i
    end
  end
end
