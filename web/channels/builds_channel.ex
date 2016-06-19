defmodule Loadmaster.BuildsChannel do
  use Loadmaster.Web, :channel

  def join("builds", _params, socket) do
    {:ok, socket}
  end
end
