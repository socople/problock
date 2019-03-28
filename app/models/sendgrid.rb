#
class Sendgrid
  #
  include SendGrid
  #
  def self.init
    @mail            = SendGrid::Mail.new
    @personalization = SendGrid::Personalization.new
    @sg              = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  def self.new(*params)
    init
    options = params.extract_options!.symbolize_keys

    setup_mail(options)
    add_recipients(options)

    self
  end

  def self.add_recipients(options)
    unless options[:to].blank?
      @personalization.add_to(SendGrid::Email.new(email: options[:to]))
    end

    return if options[:bcc].blank?
    @personalization.add_bcc(SendGrid::Email.new(email: options[:bcc]))
  end

  def self.add_to_multiple(emails)
    emails.each do |email|
      @personalization.add_to(SendGrid::Email.new(email: email))
    end
  end

  def self.setup_personalization(data)
    data.each do |key, val|
      @personalization.add_substitution(
        SendGrid::Substitution.new(key: key, value: val)
      )
    end
  end

  def self.setup_dynamic_template_data(data)
    @personalization.add_dynamic_template_data(data)
  end

  def self.setup_mail(options)
    @mail.from        = SendGrid::Email.new(email: options[:from])
    @mail.template_id = options[:template_id]
    @mail.subject     = options[:subject] unless options[:subject].blank?
  end

  def self.send
    @mail.add_personalization(@personalization)
    @sg.client.mail._('send').post(request_body: @mail.to_json)
  rescue # => e
    # puts e.message
    nil
  end
end
