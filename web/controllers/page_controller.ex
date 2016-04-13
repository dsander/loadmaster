defmodule Huginnbuilder.PageController do
  use Huginnbuilder.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
