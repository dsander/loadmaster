defmodule Huginnbuilder.RepositoryChannel do
  use Huginnbuilder.Web, :channel

  def join("repository:" <> name, _params, socket) do
    IO.inspect name
    {:ok, socket}
  end
end