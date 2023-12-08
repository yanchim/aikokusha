defmodule AikokushaWeb.SubscribeController do
  use AikokushaWeb, :controller

  action_fallback AikokushaWeb.FallbackController

  def index(conn, _params) do
    render(conn, :index, subscribe: "index")
  end

  def singbox(conn, params) do
    case params do
      %{"name" => name, "mobile" => _mobile} ->
        render(conn, :singbox, user: name, is_mobile: true)

      %{"name" => name} ->
        render(conn, :singbox, user: name, is_mobile: false)

      _ ->
        render(conn, :error)
    end
  end

  def singboxcn(conn, params) do
    case params do
      %{"mobile" => _mobile} ->
        render(conn, :singboxcn, is_mobile: true)

      _ ->
        render(conn, :singboxcn, is_mobile: false)
    end
  end

  def sscn(conn, _params) do
    render(conn, :sscn)
  end
end
