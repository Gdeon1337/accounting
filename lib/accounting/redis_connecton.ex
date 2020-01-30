defmodule Accounting.RedisConnection do
    use GenServer, restart: :permanent
    alias Redix
    require Logger

    def start_link(redis_connection) do
        GenServer.start_link(__MODULE__, redis_connection, name: __MODULE__)
    end

    def zadds(domains, timestamp) do
        GenServer.cast(__MODULE__, {:zadds, domains, timestamp})
    end

    def zrange(datetime_start, datetime_end) do
        GenServer.call(__MODULE__, {:zrange, datetime_start, datetime_end})
    end

    def ping() do
        GenServer.call(__MODULE__, :ping)
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
        {:ok, pid} = Redix.start_link(redis_connection, name: :redix)
        pid
    end

    def handle_info(msg, state) do
        Logger.warn("Error redis... MSG: #{inspect(msg)}, STATE: #{inspect(state)}")
        {:stop, :normal, state}
    end

    def handle_cast({:zadds, value, datetime}, %{:pid => pid} = state) do
        value = value
        |> Enum.map(fn domain -> ["ZADD", "urls", 0, "#{datetime}:#{domain}"] end)
        Redix.pipeline(pid, value)
        {:noreply, state}
    end


    def handle_call(:ping, _from, %{:pid => pid} = state) do
        case Redix.command(pid, ["PING"]) do
            {:ok, "PONG"} -> {:reply, :ok, state}
            _      -> {:reply, {:error, :no_connection_redis}, state}
        end
    end

    def handle_call({:zrange, datetime_start, datetime_end}, _from, %{:pid => pid} = state) do
        {:ok, values} = Redix.command(pid, ["ZREVRANGEBYLEX", "urls", "[#{datetime_end + 1}", "[#{datetime_start - 1}"])
        {:reply, values, state}
    end

end