defmodule AccountingWeb.Router do
  use AccountingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  scope "/", AccountingWeb do
    pipe_through :api
    get "/visited_domains", PageController, :index
    post "/visited_links", PageController, :create
  end

end
