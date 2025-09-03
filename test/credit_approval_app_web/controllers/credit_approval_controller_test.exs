defmodule CreditApprovalAppWeb.CreditApprovalControllerTest do
  use CreditApprovalAppWeb.ConnCase, async: true
  import Phoenix.ConnTest

  alias CreditApprovalApp.CalculatePoints
  alias CreditApprovalApp.GeneratePdf
  alias CreditApprovalApp.SendEmail

  describe "GET /risk_assesment" do
    test "renders the risk assessment form", %{conn: conn} do
      conn = get(conn, ~p"/risk_assessment")
      assert html_response(conn, 200) =~ "Risk Assessment Form"
    end
  end

  describe "POST /risk_assessment" do
    setup do
      # Prepare mocks
      :meck.new(CalculatePoints, [:non_strict])

      on_exit(fn ->
        # cleanup after each test
        :meck.unload()
      end)

      :ok
    end

    test "Redirecting to /credit_approved if points > 6", %{conn: conn} do
      details = %{"paying_job" => "yes", "consistent_12months" => "yes"}
      :meck.expect(CalculatePoints, :get_points, fn _ -> 10 end)

      conn = post(conn, ~p"/risk_assessment", %{"details" => details})
      assert redirected_to(conn) == "/credit_approved"
      assert get_session(conn, :risk_assessment_answers) == details
    end

    test "Renders credit_denied page if points <= 6", %{conn: conn} do
      details = %{"consistent_12months" => "yes"}
      :meck.expect(CalculatePoints, :get_points, fn _ -> 5 end)

      conn = post(conn, ~p"/risk_assessment", %{"details" => details})
      assert html_response(conn, 200) =~ "unable to issue credit"
      assert nil == get_session(conn, :risk_assessment_answers)
    end
  end

  describe "Get /credit_approved" do
    test "Renders the income and expense form", %{conn: conn} do
      conn = get(conn, ~p"/credit_approved")
      assert html_response(conn, 200) =~ "Income Information Form"
    end
  end

  describe "POST /credit_approved" do
    test "stores income, expense and approved amount in session", %{conn: conn} do
      details = %{"total_monthly_income" => "5000", "total_monthly_expense" => "2000"}

      conn = post(conn, ~p"/credit_approved", %{"details" => details})
      assert html_response(conn, 200) =~ "Congratulations, you have been approved for credit"
      assert get_session(conn, :income) == 5000.0
      assert get_session(conn, :expense) == 2000.0
      assert get_session(conn, :approved_amount) == "36000.00"
    end
  end

  describe "GET /email_form" do
    test "renders email form", %{conn: conn} do
      conn = get(conn, ~p"/email_form")
      assert html_response(conn, 200) =~ "Enter Your Email"
    end
  end

  describe "POST /send_email" do
    setup do
      :meck.new(GeneratePdf, [:non_strict])
      :meck.new(SendEmail, [:non_strict])

      on_exit(fn ->
        # cleanup after each test
        :meck.unload()
      end)
    end

    test "calls GeneratePdf and SendEmail then renders confirmation", %{conn: conn} do
      :meck.expect(GeneratePdf, :generate_pdf, fn _, _, _, _ -> :ok end)
      :meck.expect(SendEmail, :send_credit_email, fn _ -> {:ok, "success"} end)

      conn =
        conn
        |> init_test_session(%{
          risk_assessment_answers: %{"paying_job" => "yes"},
          income: 5000.0,
          expense: 2000.0,
          approved_amount: "36000.00"
        })

      conn =
        post(conn, ~p"/send_email", %{"details" => %{"email" => "test@example.com"}})

      assert html_response(conn, 200) =~ "Email Sent"
    end
  end
end
