defmodule AccountingWeb.FallbackController do
    use AccountingWeb, :controller

    def call(conn, {:error, :incorrect_data}) do
        conn
        |> put_status(415)
        |> json(%{status: "incorrect_data"})
    end

    def call(conn, {:error, :no_connection_redis}) do
        conn
        |> put_status(500)
        |> json(%{status: "no_connection_redis"})
    end
    
end