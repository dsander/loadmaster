defmodule Loadmaster.TurbolinksTest do
  use Loadmaster.ConnCase
  alias Loadmaster.Turbolinks

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Loadmaster.Router, :browser)
    {:ok, %{conn: conn}}
  end

  test "turbolinks_redirect does a normal redirect for get requests", %{conn: conn} do
    conn =
      conn
      |> get("/")
      |> Turbolinks.turbolinks_redirect(to: "/test")
    assert conn.status == 302
  end

  test "turbolinks_redirect stores the url in the session when the request came from turbolinks", %{conn: conn} do
    conn =
      conn
      |> put_req_header("turbolinks-referrer", "/")
      |> get("/")
      |> Turbolinks.turbolinks_redirect(to: "/test")
    assert get_session(conn, :_turbolink_location) == "/test"
  end

  test "turbolinks_redirect sends a javascript turbolinks redirect for non get requests", %{conn: conn} do
    conn =
      conn
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> post("/")
      |> Turbolinks.turbolinks_redirect(to: "/test")
    assert conn.status == 306
    assert conn.resp_body =~ "Turbolinks.visit"
  end

  test "set_turbolinks_location_header_from_session sets the Turbolinks-Location header when _turbolink_location was present in the session", %{conn: conn} do
    conn =
      conn
      |> get("/")
      |> put_req_header("turbolinks-referrer", "/")
      |> Turbolinks.turbolinks_redirect(to: "/test-location")
      |> get("/")

    turbolink_location = List.keyfind(conn.resp_headers, "Turbolinks-Location", 0)
    assert turbolink_location == {"Turbolinks-Location", "/test-location"}
  end

  test "set_content_type overrides previous content-types", %{conn: conn} do
    conn =
      conn
      |> Map.put(:resp_headers, [{"content-type", "fubar"} | conn.resp_headers])
      |> put_req_header("x-requested-with", "XMLHttpRequest")
      |> post("/")
      |> Turbolinks.turbolinks_redirect(to: "/test")
    content_type = List.keyfind(conn.resp_headers, "content-type", 0)
    refute content_type == {"content-type", "fubar"}
  end

  test "init does nothing" do
    assert Turbolinks.init(%{}) == %{}
  end

  # Copied from https://github.com/phoenixframework/phoenix/blob/0aa855d7458e075cadc7ac1db634f238e501505e/test/phoenix/controller/controller_test.exs
  defp get_resp_content_type(conn) do
    [header]  = get_resp_header(conn, "content-type")
    header |> String.split(";") |> Enum.fetch!(0)
  end

  test "turbolinks_redirect/2 with :to" do
    conn = Turbolinks.turbolinks_redirect(build_conn(:get, "/"), to: "/foobar")
    assert conn.resp_body =~ "/foobar"
    assert get_resp_content_type(conn) == "text/html"
    assert get_resp_header(conn, "location") == ["/foobar"]
    refute conn.halted

    conn = Turbolinks.turbolinks_redirect(build_conn(:get, "/"), to: "/<foobar>")
    assert conn.resp_body =~ "/&lt;foobar&gt;"

    assert_raise ArgumentError, ~r/the :to option in redirect expects a path/, fn ->
      Turbolinks.turbolinks_redirect(build_conn(:get, "/"), to: "http://example.com")
    end

    assert_raise ArgumentError, ~r/the :to option in redirect expects a path/, fn ->
      Turbolinks.turbolinks_redirect(build_conn(:get, "/"), to: "//example.com")
    end

    assert_raise ArgumentError, ~r/expected :to or :external option in /, fn ->
      Turbolinks.turbolinks_redirect(build_conn(:get, "/"), foo: :bar)
    end
  end

  test "turbolinks_redirect/2 with :external" do
    conn = Turbolinks.turbolinks_redirect(build_conn(:get, "/"), external: "http://example.com")
    assert conn.resp_body =~ "http://example.com"
    assert get_resp_header(conn, "location") == ["http://example.com"]
    refute conn.halted
  end
end
