defmodule App.Workers.SendEmail do
  use Oban.Worker, queue: :mailer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email_args}}) do
    with email <- App.Mailer.from_map(email_args),
         {:ok, _metadata} <- App.Mailer.deliver(email) do
      :ok
    end
  end
end
