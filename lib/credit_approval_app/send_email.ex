defmodule CreditApprovalApp.SendEmail do
  use Swoosh.Mailer, otp_app: :credit_approval_app

  import Swoosh.Email

  def send_credit_email(to_email) do
    new()
    |> to(to_email)
    |> from({"Credit Approval App", "no-reply@creditapp.com"})
    |> subject("Your Credit Approval Report")
    |> text_body("Please find attached your credit approval report.")
    |> attachment(Swoosh.Attachment.new("./Assessment_report.pdf"))
    |> CreditApprovalApp.Mailer.deliver()
  end
end
