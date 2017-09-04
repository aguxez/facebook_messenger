defmodule FacebookMessenger.Profile do
  @moduledoc """
  Defines configuration for the Messenger Profile API.

  Consult https://developers.facebook.com/docs/messenger-platform/reference/messenger-profile-api/
  for more information
  """

  alias FacebookMessenger.Sender

  @doc """
  Send values to configure a persistent menu.
  """
  @spec persistent_menu(list) :: %HTTPotion.Response{}
  def persistent_menu(fields) when is_list(fields) do
    body = Sender.to_json(%{
      persistent_menu: fields
    })

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Configures a Payload when the "Get Started" action is triggered.
  """
  @spec get_started(String.t) :: %HTTPotion.Response{}
  def get_started(value) when is_binary(value) do
    body = Sender.to_json(%{
      get_started: %{
        payload: value
      }
    })

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Configures a greeting text to be shown.
  """
  @spec greeting(list) :: %HTTPotion.Response{}
  def greeting(fields) when is_list(fields) do
    body = Sender.to_json(%{
      greeting: fields
    })

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Whitelist specified domains.
  """
  @spec whitelist_domains(list) :: %HTTPotion.Response{}
  def whitelist_domains(values) when is_list(values) do
    body = Sender.to_json(%{
      whitelisted_domains: values
    })

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Defines a URL to the Account Linking
  """
  @spec account_link(String.t) :: %HTTPotion.Response{}
  def account_link(url) when is_binary(url) do
    body = Sender.to_json(%{
      account_linking_url: url
    })

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Define the settings required to configure Payments on Messenger.
  """
  @spec payment_settings(String.t, String.t, list) :: %HTTPotion.Response{}
  def payment_settings(priv_key, pub_key, testers) do
    body = Sender.to_json(%{
      payment_settings: %{
        privacy_url: priv_key,
        public_key: pub_key,
        testers: testers
      }
    })

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Specifies the target audience for your Messenger bot.
  """
  @spec target_audience(String.t, map) :: %HTTPotion.Response{}
  def target_audience(value, countries_opts \\ %{}) do
    body =
      case value do
        "none" ->
          %{
            target_audience: %{
              audience_type: "none"
            }
          }
        "custom" ->
          %{
            target_audience: %{
              audience_type: "custom",
              countries: countries_opts
            }
          }
        _ ->
          %{
            target_audience: %{
              audience_type: "all"
            }
          }
      end

    # Yeah, same name.
    body = Sender.to_json(body)

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Configures settings and url for Chat Extensions.
  """
  @spec chat_extensions(String.t, list) :: %HTTPotion.Response{}
  def chat_extensions(url, opts \\ []) do
    share_button = Keyword.get(opts, :share_button, "hide")
    in_test = Keyword.get(opts, :in_test, "true")

    body = Sender.to_json(%{
      home_url: %{
        url: url,
        webview_height_radio: "tall",
        webview_share_button: share_button,
        in_test: in_test
      }
    })

    Sender.manager.post(url: Sender.profile_url(), body: body)
  end

  @doc """
  Deletes specific fields previously defined in the Profile API.
  """
  @spec delete_fields(list) :: %HTTPotion.Response{}
  def delete_fields(fields) when is_list(fields) do
    body = Sender.to_json(%{
      fields: fields
    })

    Sender.manager.delete(url: Sender.profile_url(), body: body)
  end
end
