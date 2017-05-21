defmodule Loadmaster.PageControllerTest do
  use Loadmaster.ConnCase

  test "GET /" do
    conn = get build_conn(), "/"
    assert html_response(conn, 200) =~ "Welcome to Loadmaster!"
  end
end
