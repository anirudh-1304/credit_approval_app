defmodule CreditApprovalApp.GeneratePdfTest do
  use ExUnit.Case

  alias CreditApprovalApp.GeneratePdf

  test "Should generate pdf when details given" do
    pdf_path = "./Assessment_report.pdf"

    assert :ok ==
             GeneratePdf.generate_pdf(%{"paying_job" => "yes"}, "5000.0", "2000.0", "36000.00")

    assert File.exists?(pdf_path), "Expected file #{pdf_path} to exist"
    stat = File.stat!(pdf_path)
    assert stat.size > 0, "Expected file #{pdf_path} to not be empty"
    File.rm(pdf_path)
  end
end
