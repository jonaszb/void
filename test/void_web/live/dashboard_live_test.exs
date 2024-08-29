defmodule VoidWeb.DashboardLiveTest do
  use VoidWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Void.AccountsFixtures

  describe "dashboard " do
    test "renders dashboard page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/dashboard")

      assert html =~ "Dashboard"
      assert html =~ "My rooms"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/dashboard")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    #   test "redirects to login page with a flash error if there are no valid credentials", %{
    #     conn: conn
    #   } do
    #     {:ok, lv, _html} = live(conn, ~p"/users/log_in")

    #     form =
    #       form(lv, "#login_form",
    #         user: %{email: "test@email.com", password: "123456", remember_me: true}
    #       )

    #     conn = submit_form(form, conn)

    #     assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"

    #     assert redirected_to(conn) == "/users/log_in"
    #   end
    # end

    # describe "login navigation" do
    #   test "redirects to registration page when the Register button is clicked", %{conn: conn} do
    #     {:ok, lv, _html} = live(conn, ~p"/users/log_in")

    #     {:ok, _login_live, login_html} =
    #       lv
    #       |> element(~s|main a:fl-contains("Sign up")|)
    #       |> render_click()
    #       |> follow_redirect(conn, ~p"/users/register")

    #     assert login_html =~ "Register"
    #   end

    #   test "redirects to forgot password page when the Forgot Password button is clicked", %{
    #     conn: conn
    #   } do
    #     {:ok, lv, _html} = live(conn, ~p"/users/log_in")

    #     {:ok, conn} =
    #       lv
    #       |> element(~s|main a:fl-contains("Forgot your password?")|)
    #       |> render_click()
    #       |> follow_redirect(conn, ~p"/users/reset_password")

    #     assert conn.resp_body =~ "Forgot your password?"
    #   end
  end
end
