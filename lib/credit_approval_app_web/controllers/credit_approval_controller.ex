defmodule CreditApprovalAppWeb.CreditApprovalController do
  use CreditApprovalAppWeb, :controller

  alias CreditApprovalApp.CalculatePoints
  alias CreditApprovalApp.GeneratePdf
  alias CreditApprovalApp.SendEmail

  def risk_assessment_form(conn, _params) do
    form_details =
      Phoenix.Component.to_form(
        %{
          "paying_job" => nil,
          "consistent_12months" => nil,
          "own_house" => nil,
          "own_car" => nil,
          "additional_income" => nil
        },
        as: :details
      )

    render(conn, :risk_assessment, details: form_details)
  end

  def risk_assessment(conn, %{"details" => details_input}) do
    case CalculatePoints.get_points(details_input) do
      points when points > 6 ->
        conn
        |> put_session(:risk_assessment_answers, details_input)
        |> redirect(to: ~p"/credit_approved")

      _ ->
        render(conn, :credit_denied)
    end
  end

  def approved_get_income(conn, _params) do
    form_details =
      Phoenix.Component.to_form(
        %{
          "total_monthly_income" => nil,
          "total_monthly_expense" => nil
        },
        as: :details
      )

    render(conn, :credit_approved, details: form_details)
  end

  def credit_approved(conn, %{
        "details" => %{"total_monthly_income" => income, "total_monthly_expense" => expenses}
      }) do
    income = parse_number(income)
    expenses = parse_number(expenses)
    approved_amount = ((income - expenses) * 12) |> convert_to_binary()

    conn
    |> put_session(:income, income)
    |> put_session(:expense, expenses)
    |> put_session(:approved_amount, approved_amount)
    |> render(:credit_results, approved_amount: approved_amount)
  end

  def email_form(conn, _params) do
    form_details =
      Phoenix.Component.to_form(%{"email" => nil}, as: :details)

    render(conn, :email_form, details: form_details)
  end

  def send_email(conn, %{"details" => %{"email" => email}}) do
    risk_answers = get_session(conn, :risk_assessment_answers)
    income = get_session(conn, :income) |> convert_to_binary()
    expense = get_session(conn, :expense) |> convert_to_binary()
    approved_amount = get_session(conn, :approved_amount)
    :ok = GeneratePdf.generate_pdf(risk_answers, income, expense, approved_amount)
    {:ok, _email} = SendEmail.send_credit_email(email)
    render(conn, :email_sent, email: email)
  end

  defp parse_number(val) when is_binary(val) do
    case Float.parse(val) do
      {num, _} -> num
      :error -> 0.0
    end
  end

  defp parse_number(val) when is_integer(val), do: val * 1.0
  defp parse_number(val) when is_float(val), do: val
  defp parse_number(_), do: 0.0

  defp convert_to_binary(value) do
    Float.round(value) |> :erlang.float_to_binary(decimals: 2)
  end
end
