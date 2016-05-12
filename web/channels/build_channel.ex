defmodule Loadmaster.BuildChannel do
  use Loadmaster.Web, :channel

  def join("build:" <> id, _params, socket) do
    {:ok, socket}
  end
end
