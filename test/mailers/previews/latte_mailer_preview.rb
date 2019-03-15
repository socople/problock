# Preview all emails at http://localhost:3000/rails/mailers/latte_mailer
class LatteMailerPreview < ActionMailer::Preview
  def quotation
    LatteMailer.quotation(Quotation.last)
  end
end
