defmodule ChatWeb.UserController do
  use ChatWeb, :controller

  plug :logged_in_user when action not in [:new, :create]
  plug :admin_user, [pokerface: true] when action in [:index, :delete]
  plug :correct_user when action in [:edit, :update, :delete]

  alias Chat.Accounts
  alias Chat.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  defp correct_user(
         %{
           assigns: %{current_user: current_user, admin_user: admin_user},
           params: %{"id" => id}
         } = conn,
         _params
       ) do
    id
    |> String.to_integer()
    |> is_correct_user?(current_user.id, admin_user, conn)
  end

  defp is_correct_user?(id, current_user_id, _admin_user, conn) when current_user_id == id,
    do: conn

  defp is_correct_user?(_id, _current_user_id, true, conn),
    do: conn

  defp is_correct_user?(_id, current_user_id, _admin_user, conn) do
    conn
    |> put_flash(:error, "You do not hace access to this page")
    |> redirect(to: Routes.user_path(conn, :show, current_user_id))
    |> halt()
  end
end
