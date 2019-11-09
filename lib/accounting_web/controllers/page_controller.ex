defmodule AccountingWeb.PageController do
  use AccountingWeb, :controller
  alias Accounting.Urls, as: Urls
  action_fallback AccountingWeb.FallbackController

  def index(conn, params) do
    with {:ok, urls} <- Urls.list_hosts(params) do
      json(conn, %{domains: urls, status: :ok})
    end
  end

  def create(conn, %{"links" => links}) do
    with :ok <- Urls.create_urls(links) do
      json(conn, %{status: :ok})
    end
  end

end
