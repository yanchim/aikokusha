defmodule AikokushaWeb.SubscribeControllerTest do
  use AikokushaWeb.ConnCase

  import Aikokusha.SubscribesFixtures

  alias Aikokusha.Subscribes.Subscribe

  @create_attrs %{
    id: "some id"
  }
  @update_attrs %{
    id: "some updated id"
  }
  @invalid_attrs %{id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all subscribe", %{conn: conn} do
      conn = get(conn, ~p"/api/subscribe")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create subscribe" do
    test "renders subscribe when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/subscribe", subscribe: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/subscribe/#{id}")

      assert %{
               "id" => ^id,
               "id" => "some id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/subscribe", subscribe: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update subscribe" do
    setup [:create_subscribe]

    test "renders subscribe when data is valid", %{conn: conn, subscribe: %Subscribe{id: id} = subscribe} do
      conn = put(conn, ~p"/api/subscribe/#{subscribe}", subscribe: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/subscribe/#{id}")

      assert %{
               "id" => ^id,
               "id" => "some updated id"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, subscribe: subscribe} do
      conn = put(conn, ~p"/api/subscribe/#{subscribe}", subscribe: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete subscribe" do
    setup [:create_subscribe]

    test "deletes chosen subscribe", %{conn: conn, subscribe: subscribe} do
      conn = delete(conn, ~p"/api/subscribe/#{subscribe}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/subscribe/#{subscribe}")
      end
    end
  end

  defp create_subscribe(_) do
    subscribe = subscribe_fixture()
    %{subscribe: subscribe}
  end
end
