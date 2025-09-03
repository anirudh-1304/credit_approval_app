defmodule CreditApprovalApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CreditApprovalAppWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:credit_approval_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CreditApprovalApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CreditApprovalApp.Finch},
      {ChromicPDF, []},
      # Start a worker by calling: CreditApprovalApp.Worker.start_link(arg)
      # {CreditApprovalApp.Worker, arg},
      # Start to serve requests, typically the last entry
      CreditApprovalAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CreditApprovalApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CreditApprovalAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
