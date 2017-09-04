defmodule FacebookMessenger.ProfileTest do
  use ExUnit.Case, async: false

  alias FacebookMessenger.Profile

  test "configures persistent menu" do
    field = [
      %{
        locale: "default",
        composer_input_disabled: true,
        call_to_actions: [
          %{
            title: "Account",
            type: "postback",
            payload: "ACCOUNT_PAYLOAD"
          },
          %{
            title: "Bill",
            type: "nested",
            call_to_actions: [
              %{
                title: "Pay Bill",
                type: "postback",
                payload: "PAY_PAYLOAD"
              },
              %{
                title: "Web",
                type: "web_url",
                url: "https://facebook.com"
              }
            ]
          }
        ]
      },
      %{
        locale: "zh_CN",
        composer_input_disabled: false
      }
    ]

    Profile.persistent_menu(field)

    assert_received %{
      body: "{\"persistent_menu\":[{\"locale\":\"default\",\"composer_input_disabled\":true,\"call_to_actions\":[{\"type\":\"postback\",\"title\":\"Account\",\"payload\":\"ACCOUNT_PAYLOAD\"},{\"type\":\"nested\",\"title\":\"Bill\",\"call_to_actions\":[{\"type\":\"postback\",\"title\":\"Pay Bill\",\"payload\":\"PAY_PAYLOAD\"},{\"url\":\"https://facebook.com\",\"type\":\"web_url\",\"title\":\"Web\"}]}]},{\"locale\":\"zh_CN\",\"composer_input_disabled\":false}]}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "sets get_started payload" do
    Profile.get_started("GET_STARTED_PAYLOAD")

    assert_received %{
      body: "{\"get_started\":{\"payload\":\"GET_STARTED_PAYLOAD\"}}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "sets greeting message" do
    field = [
      %{
        locale: "en_US",
        text: "Hello {{user_first_name}}!"
      },
      %{
        locale: "es_ES",
        text: "¡Hola {{user_first_name}}!"
      }
    ]

    Profile.greeting(field)

    assert_received %{
      body: "{\"greeting\":[{\"text\":\"Hello {{user_first_name}}!\",\"locale\":\"en_US\"},{\"text\":\"¡Hola {{user_first_name}}!\",\"locale\":\"es_ES\"}]}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "whitelist domains" do
    domains = ["https://google.com", "https://facebook.com"]

    Profile.whitelist_domains(domains)

    assert_received %{
      body: "{\"whitelisted_domains\":[\"https://google.com\",\"https://facebook.com\"]}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "links an url for account linking process" do
    Profile.account_link("https://facebook.com")

    assert_received %{
      body: "{\"account_linking_url\":\"https://facebook.com\"}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "sets payment_settings" do
    testers = [123, 456, 789]

    Profile.payment_settings("priv", "pub", testers)

    assert_received %{
      body: "{\"payment_settings\":{\"testers\":[123,456,789],\"public_key\":\"pub\",\"privacy_url\":\"priv\"}}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "specifies target audiences" do
    countries = %{
      whitelist: ["US", "CA"],
      blacklist: ["VE"]
    }

    Profile.target_audience("none")
    assert_received %{
      body: "{\"target_audience\":{\"audience_type\":\"none\"}}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }

    Profile.target_audience("custom", countries)
    assert_received %{
      body: "{\"target_audience\":{\"countries\":{\"whitelist\":[\"US\",\"CA\"],\"blacklist\":[\"VE\"]},\"audience_type\":\"custom\"}}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }

    # Everything else match to "all"
    Profile.target_audience("something else")
    assert_received %{
      body: "{\"target_audience\":{\"audience_type\":\"all\"}}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "chat extensions settings" do
    Profile.chat_extensions("https://youtube.com", in_test: true, share_button: "show")
    assert_received %{
      body: "{\"home_url\":{\"webview_share_button\":\"show\",\"webview_height_radio\":\"tall\",\"url\":\"https://youtube.com\",\"in_test\":true}}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end

  test "deletes listed fields" do
    Profile.delete_fields(["GET_STARTED", "GREETING", "PERSISTENT_MENU"])

    assert_received %{
      body: "{\"fields\":[\"GET_STARTED\",\"GREETING\",\"PERSISTENT_MENU\"]}", url: "https://graph.facebook.com/v2.6/me/messenger_profile?access_token=PAGE_TOKEN"
    }
  end
end
