defmodule AccountingWeb.Router do
  use AccountingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    get "/visited_domains", AccountingWeb.PageController, :index
    post "/visited_links", AccountingWeb.PageController, :create
  end

  scope "/", AccountingWeb do
    pipe_through :browser

    
  end

  # Other scopes may use custom stacks.
  # scope "/api", AccountingWeb do
  #   pipe_through :api
  # end
end
