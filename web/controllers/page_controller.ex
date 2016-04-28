defmodule Loadmaster.PageController do
  use Loadmaster.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
