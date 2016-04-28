defmodule Loadmaster.RepositoryChannel do
  use Loadmaster.Web, :channel

  def join("repository:" <> name, _params, socket) do
    {:ok, socket}
  end
end