defmodule Loadmaster.SessionControllerTest do
  use Loadmaster.ConnCase

  test "renders form for new session", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "#create logs the user in when valid credentials are provided", %{conn: conn} do
    user = insert_user(username: "admin", password: "password")
    conn = post conn, session_path(conn, :create), %{session: %{"username" => "admin", "password" => "password"}}
    assert get_flash(conn) == %{"info" => "Signed in!"}
    assert get_session(conn, :user_id) == user.id
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "#create does not log in the user when the credentials are not valid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), %{session: %{"username" => "admin", "password" => "12345"}}
    assert html_response(conn, 200) =~ "Login"
    assert get_flash(conn) == %{"error" => "Invalid username or password"}
  end

  test "#delete signs the user out" do
    user = insert_user(username: "admin")
    conn = assign(build_conn(), :current_user, user)
    conn = delete conn, session_path(conn, :delete, user)
    logged_out = get(conn, "/")

    assert logged_out.assigns.current_user == nil
    refute get_session(logged_out, :user_id)
  end
end
