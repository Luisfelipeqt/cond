defmodule App.Accounts.UserNotifier do
  import Swoosh.Email

  alias App.Mailer

  # Enfileira o email via Oban para envio assíncrono e resiliente.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"App", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with email_map <- Mailer.to_map(email),
         {:ok, _job} <- %{email: email_map} |> App.Workers.SendEmail.new() |> Oban.insert() do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    deliver_magic_link_instructions(user, url)
  end

  @doc """
  Deliver instructions to confirm the user's email address.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirme seu e-mail", """

    ==============================

    Olá #{user.email},

    Confirme sua conta clicando no link abaixo:

    #{url}

    O link expira em 7 dias.

    Se você não criou uma conta, ignore este e-mail.

    ==============================
    """)
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Link de acesso", """

    ==============================

    Olá #{user.email},

    Acesse sua conta clicando no link abaixo:

    #{url}

    Se você não solicitou este e-mail, ignore-o.

    ==============================
    """)
  end
end
