defmodule AikokushaWeb.SubscribeJSON do
  @doc """
  Renders a list of subscribe.
  """
  def index(%{subscribe: subscribe}) do
    %{data: subscribe}
  end

  def error(_params) do
    %{error: "no params"}
  end

  def sscn(_params) do
    case get_json_ss() do
      {:ok, json} -> json
      _ -> %{error: "parser error"}
    end
  end

  defp get_json_ss() do
    path =
      Path.join(
        :code.priv_dir(:aikokusha),
        "data/client-v2ray-ss.json"
      )

    with {:ok, body} <- File.read(path),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  def singbox(%{user: name, is_mobile: is_mobile}) do
    password = get_password(name)

    case if is_mobile, do: get_json_mobile(password), else: get_json(password) do
      {:ok, json} -> json
      _ -> %{error: "parser error"}
    end
  end

  defp get_password(name) do
    path = Path.join(:code.priv_dir(:aikokusha), "data/password.json")

    with {:ok, body} <- File.read(path),
         {:ok, json} <- Jason.decode(body) do
      json |> Map.get(name)
    end
  end

  def singboxcn(%{is_mobile: is_mobile}) do
    case if is_mobile, do: get_json_cnmobile(), else: get_json_cn() do
      {:ok, json} -> json
      _ -> %{error: "parser error"}
    end
  end

  defp get_json_cnmobile() do
    path = Path.join(:code.priv_dir(:aikokusha), "data/client-cnmobile.json")

    with {:ok, body} <- File.read(path),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  defp get_json_cn() do
    path = Path.join(:code.priv_dir(:aikokusha), "data/client-cn.json")

    with {:ok, body} <- File.read(path),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  defp get_json_mobile(password) do
    path = Path.join(:code.priv_dir(:aikokusha), "data/client-mobile.json")

    with {:ok, body} <- File.read(path),
         {:ok, json} <- Jason.decode(body) do
      updated_shadowtls_map =
        json
        |> Map.get("outbounds")
        |> Enum.filter(fn x -> x["type"] == "shadowtls" end)
        |> List.first()
        |> Map.get_and_update("password", fn x -> {x, password} end)
        |> elem(1)

      updated_outbounds_map =
        json
        |> Map.get("outbounds")
        |> Enum.map(fn x ->
          if x["type"] == "shadowtls",
            do: updated_shadowtls_map,
            else: x
        end)

      json =
        json |> Map.get_and_update("outbounds", fn x -> {x, updated_outbounds_map} end) |> elem(1)

      {:ok, json}
    end
  end

  defp get_json(password) do
    path = Path.join(:code.priv_dir(:aikokusha), "data/client.json")

    with {:ok, body} <- File.read(path),
         {:ok, json} <- Jason.decode(body) do
      updated_shadowtls_map =
        json
        |> Map.get("outbounds")
        |> Enum.filter(fn x -> x["type"] == "shadowtls" end)
        |> List.first()
        |> Map.get_and_update("password", fn x -> {x, password} end)
        |> elem(1)

      updated_outbounds_map =
        json
        |> Map.get("outbounds")
        |> Enum.map(fn x ->
          if x["type"] == "shadowtls",
            do: updated_shadowtls_map,
            else: x
        end)

      json =
        json |> Map.get_and_update("outbounds", fn x -> {x, updated_outbounds_map} end) |> elem(1)

      {:ok, json}
    end
  end
end
