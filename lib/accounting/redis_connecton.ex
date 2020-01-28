defmodule Accounting.RedisConnection do
    use GenServer, restart: :permanent
    import Exredis.Api
    require Logger

    def start_link(redis_connection) do
        GenServer.start_link(__MODULE__, redis_connection, name: __MODULE__)
    end

    def init(redis_connection) do
        Process.flag(:trap_exit, true)
        Logger.info("Redis connection created...")
        initial_state = %{
            pid: connection(redis_connection)
        } 
        Logger.info("Redis connection successfull create")
        {:ok, initial_state}
    end

    defp connection(redis_connection) do
        Exredis.start_using_connection_string(redis_connection)
    end

    def handle_info(msg, state) do
        Logger.warn("Error redis... MSG: #{inspect(msg)}, STATE: #{inspect(state)}")
        {:stop, :normal, state}
    end

    def handle_call(:get, _from, %{:pid => pid} = state) do
        {:reply, pid, state}
    end

    def handle_cast({:zadds, value}, %{:pid => pid} = state) do
        Logger.info(inspect(value))
        pid 
        |> Exredis.query_pipe(value)
        {:noreply, state}
    end


    def handle_call(:ping, _from, %{:pid => pid} = state) do
        values = pid 
            |> ping
        {:reply, values, state}
    end

    def handle_call({:zrange, date_start, date_end}, _from, %{:pid => pid} = state) do
        values = pid 
            |> Exredis.query(["ZREVRANGEBYLEX", "urls", "[#{date_end+1}", "[#{date_start-1}"])
        {:reply, values, state}
    end

end