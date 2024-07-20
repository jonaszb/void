defmodule MultiProviderAuth do
  alias Assent.Config

  @spec request(atom()) :: {:ok, map()} | {:error, term()}
  def request(provider) do
    config = config!(provider)

    config[:strategy].authorize_url()
  end

  @spec callback(atom(), map(), map()) :: {:ok, map()} | {:error, term()}
  def callback(provider, params, session_params) do
    config = config!(provider)

    config
    |> Assent.Config.put(:session_params, session_params)
    |> config[:strategy].callback(params)
  end

  defp config!(provider) do
    config =
      Application.get_env(:my_app, :strategies)[provider] ||
        raise "No provider configuration for #{provider}"

    Config.put(config, :redirect_uri, "http://localhost:4000/oauth/#{provider}/callback")
  end
end
