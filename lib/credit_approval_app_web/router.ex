defmodule CreditApprovalAppWeb.Router do
  use CreditApprovalAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CreditApprovalAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CreditApprovalAppWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/risk_assessment", CreditApprovalController, :risk_assessment_form
    post "/risk_assessment", CreditApprovalController, :risk_assessment
    get "/credit_approved", CreditApprovalController, :approved_get_income
    post "/credit_approved", CreditApprovalController, :credit_approved
    get "/email_form", CreditApprovalController, :email_form
    post "/send_email", CreditApprovalController, :send_email
  end

  # Other scopes may use custom stacks.
  # scope "/api", CreditApprovalAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:credit_approval_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CreditApprovalAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
