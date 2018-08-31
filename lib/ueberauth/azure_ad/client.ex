defmodule Ueberauth.Strategy.AzureAD.Client do
  @moduledoc """
  Oauth2 client for Azure Active Directory.
  """

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  def logout_url() do
  	configset = config()
    tenant = configset[:tenant]
    client_id = configset[:client_id]
    "https://login.microsoftonline.com/#{tenant}/oauth2/logout?client_id=#{client_id}"
  end

  def authorize_url!(callback_url) do
    oauth_session = SecureRandom.uuid
    
    params =
      %{}
      |> Map.update(:response_mode, "form_post", &(&1 * "form_post"))
      |> Map.update(:response_type, "code id_token", &(&1 * "code id_token"))
      |> Map.update(:nonce, oauth_session, &(&1 * oauth_session))

    build_client(callback_url)
    |> Client.authorize_url!(params)
  end

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  defp build_client(callback_url) do
  	configset = config()

  	Client.new([
      strategy: __MODULE__,
      client_id: configset[:client_id],
      redirect_uri: callback_url,
      authorize_url: "https://login.microsoftonline.com/#{configset[:tenant]}/oauth2/authorize",
      token_url: "https://login.microsoftonline.com/#{configset[:tenant]}/oauth2/token"
    ])
  end

  def configured? do 
    configset = config() 
    configset != nil
    && Keyword.has_key?(configset, :tenant) 
    && Keyword.has_key?(configset, :client_id) 
  end 

  defp config do
    Application.get_env(:ueberauth, Ueberauth.Strategy.AzureAD)
  end
end
