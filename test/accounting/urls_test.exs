defmodule Accounting.UrlsTest do
  use Accounting.DataCase

  alias Accounting.Urls
  
  @links_data [
    "https://ya.ru",
    "https://ya.ru?q=123",
    "funbox.ru",
    "https://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor"
  ]

  @valid_url "https://ya.ru?q=123"
  @valid_host "ya.ru"
  @invalid_url "yaru?q=123"
  @date_time DateTime.utc_now() |> DateTime.to_unix() |> to_string



  describe "Urls" do
    test "create_urls" do
      status = Urls.create_urls(@links_data)
      assert status == :ok
    end

    test "list_host_invalid_params_from" do
      status = Urls.list_hosts(%{"from" => "invalid_params", "to" => @date_time})
      assert status == {:error, :incorrect_data}
    end

    test "list_host_invalid_params_to" do
      status = Urls.list_hosts(%{"from" => @date_time, "to" => "invalid_params"})
      assert status == {:error, :incorrect_data}
    end

    test "list_host_valid_params" do
      status = Urls.list_hosts(%{"from" => @date_time, "to" => @date_time})
      assert status != {:error, :incorrect_data}
    end
  end
end  