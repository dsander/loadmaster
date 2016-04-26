defmodule Huginnbuilder.RepositoryChannel do
  use Huginnbuilder.Web, :channel

  def join("repository:" <> name, _params, socket) do
    {:ok, socket}
  end
end