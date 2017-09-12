# ExFacebookMessenger
[![Build Status](https://travis-ci.org/oarrabi/facebook_messenger.svg?branch=master)](https://travis-ci.org/oarrabi/facebook_messenger)
[![Hex.pm](https://img.shields.io/hexpm/v/facebook_messenger.svg)](https://hex.pm/packages/facebook_messenger)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/facebook_messenger/)
[![Coverage Status](https://coveralls.io/repos/github/oarrabi/facebook_messenger/badge.svg?branch=master)](https://coveralls.io/github/oarrabi/facebook_messenger?branch=master)
[![Inline docs](http://inch-ci.org/github/oarrabi/facebook_messenger.svg?branch=master)](http://inch-ci.org/github/oarrabi/facebook_messenger)

ExFacebookMessenger is a library that helps you create facebook messenger bots easily.

## Installation

```elixir
def deps do
  [{:facebook_messenger, "~> 0.3.0"}]
end
```


## Usage

### With plug
To create an echo back bot, do the following:

In your `Plug.Router` define a `forward` with a route to `FacebookMessenger.Router`

```elixir
defmodule Sample.Router do
  use Plug.Router
  ...

  forward "/messenger/webhook",
    to: FacebookMessenger.Router,
    message_received: &Sample.Router.message/1

  def message(msg) do
    message = FacebookMessenger.Response.parse(msg)
      |> FacebookMessenger.Response.get_messaging

    case message.type do
      "postback" -> YourApplication.process_postback(message)
      "message" -> YourApplication.proccess_text_message(message)
      _ -> YourApplication.handle_default(message)
    end
  end
end

defmodule YourApplication do
  def process_postback(message) do
    sender = FacebookMessenger.Response.message_senders(message)

    case message.payload do
      "USER_CLICKED_BUTTON" -> FacebookMessenger.Sender.send(sender, "You have clicked the button")
      _ -> FacebookMessenger.Sender.send(sender, "I can't handle this message")
    end
  end


  def process_text_message(message) do
    text = FacebookMessenger.Response.message_texts(message)
    sender = FacebookMessenger.Response.message_senders(message)
    FacebookMessenger.Sender.send(sender, text)
  end
end

```

This defines a webhook endpoint at:
`http://your-app-url/messenger/webhook`

Go to your `config/config.exs` and add the required configurations

```elixir
config :facebook_messenger,
      facebook_page_token: "Your facebook page token",
      challenge_verification_token: "the challenge verify token"
```

To get the `facebook_page_token` and `challenge_verification_token` follow the instructions [here ](https://developers.facebook.com/docs/messenger-platform/quickstart)

For the webhook endpoint use `http://your-app-url/messenger/webhook`

### With Phoenix
If you use phoenix framework in your project, then you need the phoenix version of `facebook_messenger` this can be found at `phoenix_facebook_messenger` [found here](https://github.com/oarrabi/phoenix_facebook_messenger).

### How to use the `body` macro to send other type of messages besides text and image.

The macro receives 3 arguments, `id, :template, "Text"` <- Text is provided only if the template requires it, otherwise it's optional.

This example shows how to send a message with Quick Replies.
```elixir
...
import FacebookMessenger.Builder

def process_message(_msg) do
  body id, :quick_replies, "Quick replies test" do
    # fields is the function to define the body of the request
    fields %{
      quick_replies: [
        %{
          content_type: "location"
        },
        %{
          content_type: "text",
          title: "red"
        }
      ]
    }
  end
end
```

An example using the list template can be written as follows:
```elixir
def some_function(_msg) do
  body 123, :list_template do
    fields %{
      template_type: "list",
      top_element_style: "compact",
      elements: [
        %{
          title: "Classic shirt",
          subtitle: "First subtitle"
        },
        %{
          title: "Classic shirt 2",
          subtitle: "Second subtitle"
        }
      ]
    }
  end
end
```

Go to [Messenger's docs](https://developers.facebook.com/docs/messenger-platform/reference/send-api) to see other types you can use. Follow the same convention.

For now, only working:
1. Every button type
2. Quick replies
3. Button, Generic, List templates

## Sample

- A sample facebook echo bot with plug can be found here. https://github.com/oarrabi/plug_facebook_echo_bot
- For the phoenix echo bot, https://github.com/oarrabi/phoenix_facebook_echo_bot

## Future Improvements

- [ ] Handle other types of facebook messages
- [ ] Support sending facebook structure messages
- [x] Handle facebook postback messages

