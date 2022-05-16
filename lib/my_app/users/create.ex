defmodule MyApp.Users.Create do
  alias MyApp.{Repo, User}

  alias MyApp.ViaCep.HttpoisonClient, as: Client

  @type user_params :: %{
          first_name: String.t(),
          last_name: integer,
          cep: String.t(),
          email: String.t()
        }

  @doc """
  Inserts a user into the database.

  ## Examples

      iex> alias MyApp.{User, Users}
      ...>
      ...> user_params = %{
      ...>  first_name: "Mike",
      ...>  last_name: "Wazowski",
      ...>  cep: "95270000",
      ...>  email: "mike_wazowski@monstros_sa.com"
      ...> }
      ...>
      ...> {:ok, %User{}} = Users.Create.call user_params
  """
  @spec call(user_params()) :: {:error, Ecto.Changeset.t() | map()} | {:ok, Ecto.Schema.t()}
  def call(params) do
    cep = Map.get(params, :cep)

    changeset = User.changeset(%User{}, params)

    with {:ok, %User{}} <- User.validate_before_insert(changeset),
         {:ok, %{"localidade" => city, "uf" => uf}} <- Client.get_cep_info(cep),
         %{} = _params <- Map.merge(params, %{city: city, uf: uf}),
         {:ok, %User{}} = user <- Repo.insert(changeset) do
      user
    end
  end
end
