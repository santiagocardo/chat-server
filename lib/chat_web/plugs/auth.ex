defmodule Chat.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias ChatWeb.Router.Helpers
  alias ChatWeb.ErrorView

  def init(opts), do: opts

  def call(conn, _opts) do
    get_session(conn, :user_id)
    |> get_user()
    |> put_current_user(conn)
  end

  def logged_in_user(conn = %{assigns: %{current_user: %{}}}, _opts), do: conn

  def logged_in_user(conn, _opts) do
    conn
    |> put_flash(:error, "You must be logged in to access this page")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end

  def admin_user(conn = %{assigns: %{admin_user: true}}, _opts), do: conn

  def admin_user(conn, %{pokerface: true}) do
    conn
    |> put_status(404)
    |> render(ErrorView, :"404", message: "Page not found")
    |> halt()
  end

  def admin_user(conn, _opts) do
    conn
    |> put_flash(:error, "You do not have access to this page")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end

  defp get_user(nil = _user_id), do: nil
  defp get_user(user_id), do: Chat.Accounts.get_user!(user_id)

  defp put_current_user(user, conn) do
    conn
    |> assign(:current_user, user)
    |> assign(:admin_user, user && user.credential.email == "santiagocardo80@gmail.com")
  end
end
