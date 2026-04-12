defmodule App.Marketing do
  alias App.Repo
  alias App.Marketing.Contact

  def change_contact(attrs \\ %{}) do
    Contact.changeset(attrs)
  end

  def create_contact(attrs) do
    attrs
    |> Contact.changeset()
    |> Repo.insert()
  end
end
