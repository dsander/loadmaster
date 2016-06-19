defmodule Loadmaster.Turbolinks do
 import Plug.Conn
 import Phoenix.Controller, only: [redirect: 2]

  def init(opts), do: opts

  def call(%{req_headers: req_headers} = conn, opts) do
    conn
    |> set_turbolinks_location_header_from_session
  end

  def turbolinks_redirect(%{req_headers: req_headers} = conn, opts) when is_list(opts) do
    requested_with      = List.keyfind(req_headers, "x-requested-with", 0)
    location = url(opts)
    if (requested_with && elem(requested_with, 1) == "XMLHttpRequest") && conn.method != "GET" do
      body = "Turbolinks.clearCache()\n" <>
             "Turbolinks.visit(#{Poison.encode!(location)}, #{Poison.encode!(%{action: "advance"})})"

      conn
      |> set_content_type("text/javascript; charset=utf-8")
      |> send_resp(306, body)
    else
      if List.keyfind(req_headers, "turbolinks-referrer", 0) do
        conn = store_turbolinks_location_in_session(conn, location)
      end
      redirect(conn, opts)
    end
  end

  defp url(opts) do
    cond do
      to = opts[:to] ->
        case to do
          "//" <> _ -> raise_invalid_url()
          "/" <> _  -> to
          _         -> raise_invalid_url()
        end
      external = opts[:external] ->
        external
      true ->
        raise ArgumentError, "expected :to or :external option in turbolinks_redirect/2"
    end
  end

  defp raise_invalid_url do
    raise ArgumentError, "the :to option in redirect expects a path"
  end

  defp set_content_type(%{resp_headers: resp_headers} = conn, content_type) do
    if List.keyfind(resp_headers, "content-type", 0) do
      %{conn | resp_headers: List.keyreplace(resp_headers, "content-type", 0, {"content-type", content_type})}
    else
      %{conn | resp_headers: [{"content-type", content_type}|resp_headers]}
    end
  end

  defp set_turbolinks_location_header_from_session(%{resp_headers: resp_headers} = conn) do
    if get_session(conn, :_turbolink_location) do
      conn = %{conn | resp_headers: [{"Turbolinks-Location", get_session(conn, :_turbolink_location)} | resp_headers]}
      conn = delete_session(conn, :_turbolink_location)
      conn
    else
      conn
    end
  end

  defp store_turbolinks_location_in_session(%{resp_headers: resp_headers} = conn, location) do
    put_session(conn, :_turbolink_location, location)
  end
end
