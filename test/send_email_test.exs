defmodule CreditApprovalApp.SendEmailTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions

  alias CreditApprovalApp.GeneratePdf
  alias CreditApprovalApp.SendEmail

  test "sends credit email with attachment" do
    assert :ok ==
             GeneratePdf.generate_pdf(%{"paying_job" => "yes"}, "5000.0", "2000.0", "36000.00")

    to_email = "user@example.com"
    {:ok, _email} = SendEmail.send_credit_email(to_email)

    assert_email_sent(fn email ->
      assert email.to == [{"", to_email}]
      assert email.from == {"Credit Approval App", "no-reply@creditapp.com"}
      assert email.subject == "Your Credit Approval Report"
      assert email.text_body =~ "Please find attached"
      assert length(email.attachments) == 1

      [attachment] = email.attachments
      assert attachment.filename == "Assessment_report.pdf"
      File.rm("./Assessment_report.pdf")
    end)
  end
end
