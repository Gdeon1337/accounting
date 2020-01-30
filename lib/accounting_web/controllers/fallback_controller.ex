defmodule AccountingWeb.FallbackController do
    use AccountingWeb, :controller
    alias AccountingWeb.ErrorView, as: ErrorView 

    def call(conn, {:error, :incorrect_data}) do
        conn
        |> put_status(415)
        |> render(ErrorView, "error.json", %{status: "Incorrect data"})
    end

    def call(conn, {:error, :no_connection_redis}) do
        conn
        |> put_status(500)
        |> render(ErrorView, "error.json", %{status: "Redis disconnected"})
    end

    def call(conn, {:error, _message}) do
        conn
        |> put_status(500)
        |> render(ErrorView, "error.json", %{status: "Unknown error"})
    end
    
end