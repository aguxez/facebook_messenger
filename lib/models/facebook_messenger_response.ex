defmodule FacebookMessenger.Response do
  @moduledoc """
  Facebook messenger response structure
  """

  @derive [Poison.Encoder]
  @postback_regex ~r/postback/
  defstruct [:object, :entry]

  @doc """
  Decode a map into a `FacebookMessenger.Response`
  """
  @spec parse(map) :: FacebookMessenger.Response.t
  def parse(param) when is_map(param) do
    decoder =
      param
      |> get_parser
      |> decoding_map

    Poison.Decode.decode(param, as: decoder)
  end

  @doc """
  Decode a string into a `FacebookMessenger.Response`
  """
  @spec parse(String.t) :: FacebookMessenger.Response.t
  def parse(param) when is_binary(param) do
    decoder =
      param
      |> get_parser
      |> decoding_map

    {:ok, result} = Poison.decode(param, as: decoder)
    result
  end

  def parse(_), do: :error

  @doc """
  Get shorter representation of message data
  """
  @spec get_messaging(FacebookMessenger.Response.t) :: FacebookMessenger.Messaging.t
  def get_messaging(%{entry: entries}) do
    entries
    |> hd
    |> Map.get(:messaging)
    |> hd
  end

  @doc """
  Return an list of message texts from a `FacebookMessenger.Response`
  """
  @spec message_texts(FacebookMessenger.Response) :: [String.t]
  def message_texts(%{entry: entries}) do
    entry_map =
      entries
      |> get_messaging_struct
      |> Enum.find_value(&(&1.message))

    case entry_map do
      nil -> :error
      _ -> entry_map.text
    end
  end

  @doc """
  Return an list of message sender Ids from a `FacebookMessenger.Response`
  """
  @spec message_senders(FacebookMessenger.Response) :: [String.t]
  def message_senders(%{entry: entries}) do
    entry_map =
      entries
      |> get_messaging_struct
      |> Enum.find_value(&(&1.sender))

    case entry_map do
      nil -> nil
      _ -> entry_map.id
    end
  end

  @doc """
  Return user defined postback payload from a `FacebookMessenger.Response`
  """
  @spec get_postback(FacebookMessenger.Response) :: FacebookMessenger.Postback.t
  def get_postback(%{entry: entries}) do
    entries
    |> get_messaging_struct
    |> Enum.find_value(&(&1.postback))
  end

  defp get_parser(param) when is_binary(param) do
    cond do
      String.match?(param, @postback_regex) -> postback_parser()
      true -> text_message_parser()
    end
  end

  defp get_parser(%{"entry" => entries} = param) when is_map(param) do
    messaging =
      entries
      |> get_messaging_struct("messaging")
      |> List.first

    # One condition needs to always match, the previous version
    # of below get_messaging_struct/2 function sometimes raised
    # exceptions on this conditional because none matched.
    cond do
      Map.has_key?(messaging, "postback") -> postback_parser()
      true -> text_message_parser()
    end
  end

  # Depending on the type of subscriptions you have on your page
  # the messages can be nil or not.
  defp get_messaging_struct(entries, messaging_key \\ :messaging) do
    result = Enum.flat_map(entries, &Map.get(&1, messaging_key))

    case result do
      nil -> :error
      result -> result
    end
  end

  defp postback_parser do
    %FacebookMessenger.Messaging{
      "type": "postback",
      "sender": %FacebookMessenger.User{},
      "recipient": %FacebookMessenger.User{},
      "postback": %FacebookMessenger.Postback{}
    }
  end

  defp text_message_parser do
    %FacebookMessenger.Messaging{
      "type": "message",
      "sender": %FacebookMessenger.User{},
      "recipient": %FacebookMessenger.User{},
      "message": %FacebookMessenger.Message{}
    }
  end

  # Better to do nothing instead of raising exceptions.
  defp decoding_map(messaging_parser) when is_map(messaging_parser) do
    %FacebookMessenger.Response{
      "entry": [%FacebookMessenger.Entry{
        "messaging": [messaging_parser]
      }]}
  end

  defp decoding_map(_), do: :error

   @type t :: %FacebookMessenger.Response{
    object: String.t,
    entry: FacebookMessenger.Entry.t
  }
end
