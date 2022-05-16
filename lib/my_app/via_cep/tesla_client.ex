defmodule MyApp.ViaCep.TeslaClient do
  # use Tesla -> Para usar as funções do Tesla sem precisar colocar sempre a palavra Tesla na frente da função.
  # Exemplo: ao invés de Tesla.get(), vc vai usar apenas get()
  use Tesla

  alias Tesla.Env

  # contrato para a função `get_cep_info`
  # deve sempre receber uma string e devolver {:ok, map()} ou {:error, map()}
  @behaviour MyApp.ViaCep.Behaviour

  @base_url "https://viacep.com.br/ws/"

  # codifica (encode) os parametros para json
  # e descodifica (decode) a resposta para json automaticamente.
  plug Tesla.Middleware.JSON

  def get_cep_info(url \\ @base_url, cep) do
    "#{url}#{cep}/json/"
    |> get()
    |> handle_get()
  end

  # casos abaixo de sucesso e erro
  defp handle_get({:ok, %Env{status: 200, body: %{"erro" => "true"}}}) do
    {:error, %{status: :not_found, result: "CEP not found!"}}
  end

  defp handle_get({:ok, %Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_get({:ok, %Env{status: 400, body: _body}}) do
    {:error, %{status: :bad_request, result: "Invalid CEP!"}}
  end

  defp handle_get({:error, reason}) do
    {:error, %{status: :bad_request, result: reason}}
  end
end
