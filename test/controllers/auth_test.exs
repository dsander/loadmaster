defmodule Loadmaster.AuthTest do
  use Loadmaster.ConnCase
  alias Loadmaster.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Loadmaster.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
  end

  test "authenticate_user continues when current_user is assigned", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Loadmaster.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the current_user in the session", %{conn: conn} do
    user = insert_user(%{username: "tester", password: "password"})
    login_conn =
      conn
      |> Auth.login(user)
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == user.id
  end

  test "logout unsets the current_user in the session", %{conn: conn} do
    user = insert_user(%{username: "tester", password: "password"})
    logout_conn =
      conn
      |> put_session(:current_user, user.id)
      |> Auth.logout
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "login_by_username_and_password assigns the current_user when the login matches", %{conn: conn} do
    user = insert_user(%{username: "tester", password: "password"})
    {:ok, conn} = Auth.login_by_username_and_password(conn, "tester", "password", repo: Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "login_by_username_and_password returns an error when the password does not match", %{conn: conn} do
    _ = insert_user(%{username: "tester", password: "password"})
    {:error, :unauthorized, _} = Auth.login_by_username_and_password(conn, "tester", "1234", repo: Repo)
  end

  test "login_by_username_and_password returns an error when the username does not exist", %{conn: conn} do
    _ = insert_user(%{username: "tester", password: "password"})
    {:error, :not_found, _} = Auth.login_by_username_and_password(conn, "1234", "password", repo: Repo)
  end
end
