#
class LatteMailer < ApplicationMailer
  ##
  # Pass this method as delivery_method_options option to mail()
  # to use setting from Latte
  def delivery_options
    {
      address:              Setting.smtp_host,
      port:                 Setting.smtp_port,
      domain:               Setting.smtp_domain,
      user_name:            Setting.smtp_username,
      password:             Setting.smtp_password,
      authentication:       'plain',
      enable_starttls_auto: true
    }
  end

  def test_email(email = Setting.inbox_email, name = Setting.inbox_name)
    from = "#{name} <#{email}>"
    to   = "#{name} <#{email}>"

    mail from: from,
         to: to,
         subject: 'Hello from Latte CMS!',
         delivery_method_options: delivery_options
  end
end
