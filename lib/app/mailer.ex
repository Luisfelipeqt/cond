defmodule App.Mailer do
  use Swoosh.Mailer, otp_app: :app

  def to_map(%Swoosh.Email{} = email) do
    %{
      "to" => contact_to_map(email.to),
      "from" => contact_to_map(email.from),
      "subject" => email.subject,
      "text_body" => email.text_body
    }
  end

  def from_map(%{"to" => to, "from" => from, "subject" => subject, "text_body" => text_body}) do
    Swoosh.Email.new(
      to: map_to_contact(to),
      from: map_to_contact(from),
      subject: subject,
      text_body: text_body
    )
  end

  defp contact_to_map(info) when is_list(info), do: Enum.map(info, &contact_to_map/1)
  defp contact_to_map({name, email}), do: %{"name" => name, "email" => email}

  defp map_to_contact(info) when is_list(info), do: Enum.map(info, &map_to_contact/1)
  defp map_to_contact(%{"name" => name, "email" => email}), do: {name, email}
end
