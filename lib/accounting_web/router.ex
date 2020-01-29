defmodule AccountingWeb.Router do
  use AccountingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  scope "/api", AccountingWeb do
    pipe_through :api
    resources "/domains", PageController, only: [:index, :create]
  end

end
