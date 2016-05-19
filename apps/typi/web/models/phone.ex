defmodule Typi.Phone do
  use Typi.Web, :model

  schema "phones" do
    field :country_code, :string
    field :number, :string
    field :region, :string
    belongs_to :user, Typi.User

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:country_code, :number, :region])
    |> validate_required([:country_code, :number, :region])
    |> validate_phone
    |> unique_constraint(:number, name: :phones_country_code_number_index)
  end

  def validate_phone(changeset) do
    # TODO change to with else when elixir 1.3 is out
    # TODO improve implementation
    with %Ecto.Changeset{valid?: true, changes:
          %{country_code: country_code, number: number, region: region}} <- changeset,
        {:ok, phone_number} <- ExPhoneNumber.parse("#{country_code}#{number}", region),
        true <- ExPhoneNumber.is_valid_number?(phone_number) do
      {:ok, phone_number}
    end
    |> case do
      {:ok, _} -> changeset
      _ -> add_error(changeset, :number, "not valid")
    end
  end
end