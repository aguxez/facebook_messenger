defmodule FacebookMessenger.RequestManager do
  @moduledoc """
  Module responsible to post a request to Facebook.
  """
  def post(url: url, body: body) do
    HTTPotion.post url,
    body: body, headers: ["Content-Type": "application/json"]
  end

  def delete(url: url, body: body) do
    HTTPotion.delete(url, body: body, headers: ["Content-Type": "application/json"])
  end
end

defmodule FacebookMessenger.RequestManager.Mock do
  @moduledoc """
  Mock responsible to post a request to Facebook.
  """

  def post(url: url, body: body) do
    send(self(), %{url: url, body: body})
  end

  def delete(url: url, body: body) do
    send(self(), %{url: url, body: body})
  end
end
