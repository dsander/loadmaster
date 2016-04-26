defmodule Huginnbuilder.BuildChannel do
  use Huginnbuilder.Web, :channel

  def join("build:" <> id, _params, socket) do
    {:ok, socket}
  end
end