defmodule AccountingWeb.PageControllerTest do
  use AccountingWeb.ConnCase
  
  @output_domains [
        "funbox.ru",
        "stackoverflow.com",
        "ya.ru"
  ]

  @links_data %{
    "links" => [
      "https://ya.ru",
      "https://ya.ru?q=123",
      "funbox.ru",
      "https://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor"
    ]
  }

  @date_time DateTime.utc_now() |> DateTime.to_unix()

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create links" do  
    test "renders host when data is valid", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :create), @links_data)
      assert %{ "status" => "ok" } = json_response(conn, 200)
    end
  end


  describe "index" do
    test "lists Urls", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :create), @links_data)
      to = DateTime.utc_now() |> DateTime.to_unix()
      conn = get(conn, Routes.page_path(conn, :index, from: @date_time, to: to))
      response =  for {key, val} <- json_response(conn, 200), into: %{}, do: {String.to_atom(key), val}
      assert response.status == "ok"
      assert Enum.sort(response.domains) == @output_domains
    end

    test "Invalid params", %{conn: conn} do
      conn = post(conn, Routes.page_path(conn, :create), @links_data)
      to = DateTime.utc_now() |> DateTime.to_unix()
      conn = get(conn, Routes.page_path(conn, :index, from: "invalid_params", to: to))
      assert json_response(conn, 415) == %{"status" => "Incorrect data"}
      conn = get(conn, Routes.page_path(conn, :index, from: @date_time, to: "invalid_params"))
      assert json_response(conn, 415) == %{"status" => "Incorrect data"}
    end
  end

end
