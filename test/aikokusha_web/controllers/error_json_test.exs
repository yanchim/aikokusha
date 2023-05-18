defmodule AikokushaWeb.ErrorJSONTest do
  use AikokushaWeb.ConnCase, async: true

  test "renders 404" do
    assert AikokushaWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AikokushaWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
