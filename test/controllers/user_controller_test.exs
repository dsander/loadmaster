defmodule Loadmaster.UserControllerTest do
  use Loadmaster.ConnCase

  alias Loadmaster.User
  @valid_attrs %{email: "some content", username: "some content"}
  @invalid_attrs %{}

  setup do
    user = insert_user(username: "admin")
    conn = assign(conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Registration"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: Dict.merge(@valid_attrs, %{invitation_token: "try-loadmaster", password: "password"})
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Registration"
  end

  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "it only renders the edit form when the id matches the current user", %{conn: conn} do
    bob = insert_user(username: "bob")
    conn = get conn, user_path(conn, :edit, bob)
    assert redirected_to(conn) == page_path(conn, :index)
    assert get_flash(conn, :error) == "User not found"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: %{email: "email", username: "email", password: "password"}
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(User, %{email: "email", username: "email"})
  end

  test "it only updates the user when the id matches the current user", %{conn: conn} do
    bob = insert_user(username: "bob")
    conn = put conn, user_path(conn, :update, bob), user: %{email: "email", username: "email", password: "password"}
    assert redirected_to(conn) == page_path(conn, :index)
    assert get_flash(conn, :error) == "User not found"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == page_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  test "it does not delete the user when the id does not match the current_user", %{conn: conn, user: user} do
    bob = insert_user(username: "bob")
    conn = delete conn, user_path(conn, :delete, bob)
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get(User, user.id)
    assert get_flash(conn, :error) == "User not found"
  end
end
