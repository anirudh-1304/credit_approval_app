defmodule CreditApprovalApp.GeneratePdf do
  def generate_pdf(risk_answers, income, expense, approved_amount) do
    html = """
    <h1>Credit Approval Report</h1>
    <p><b>Risk Assessment Answers:</b></p>
    <p>Do you have a Paying Job?: #{risk_answers["paying_job"]}</p>
    <p>Do you consistently had a paying job for past 12 months?: #{risk_answers["consistent_12months"]}</p>
    <p>Do you own a home?: #{risk_answers["own_house"]}</p>
    <p>Do you own a car?: #{risk_answers["own_car"]}</p>
    <p>Do you have any additional source of income?: #{risk_answers["additional_income"]}</p>
    <p><b>Total Monthly Income:</b> #{income} USD</p>
    <p><b>Total Monthly Expense:</b> #{expense} USD</p>
    <p><b>Approved Credit:</b> #{approved_amount} USD</p>
    """

    ChromicPDF.print_to_pdf({:html, html}, output: "Assessment_report.pdf")
  end
end
