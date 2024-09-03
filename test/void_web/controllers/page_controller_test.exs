defmodule VoidWeb.PageControllerTest do
  use VoidWeb.ConnCase

  describe "GET /" do
    test "Renders main heading", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Real-time collaboration"
    end

    test "Renders testimonials", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Bill Gates"
      assert html_response(conn, 200) =~ "Donald Trump"
    end

    test "Renders login link", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Sign in to get started"
    end
  end
end
