defmodule AccountingWeb.PageController do
  use AccountingWeb, :controller
  alias Accounting.Urls, as: Urls
  action_fallback AccountingWeb.FallbackController

  def index(conn, %{"from" => from, "to"=> to}) do
    with {:ok, urls} <- Urls.list_hosts(from, to) do
      render(conn, "index.json", %{domains: urls, status: :ok})
    end
  end

  def create(conn, %{"links" => links}) do
    with :ok <- Urls.create_urls(links) do
      render(conn, "create.json", %{status: :ok})
    end
  end

end
