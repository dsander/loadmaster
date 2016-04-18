defmodule Huginnbuilder.WebhookController do
  use Huginnbuilder.Web, :controller

  def handle(conn, params) do
    data = Poison.encode!(params)
    {epoch, sec, msec} = :erlang.timestamp()
    filename = Integer.to_string(epoch) <> Integer.to_string(sec) <> Integer.to_string(msec) <> ".json"
    File.write!(Huginnbuilder.Endpoint.config(:root) <> "/test/fixtures/" <> filename, data)
    conn
    |> put_status(200)
    |> json(:ok)
  end
end