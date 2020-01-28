defmodule Accounting.Urls do
    alias Accounting.RedisConnection, as: Client
    import Exredis.Api
    import Exredis
    require Logger


    defp check_connection() do
        case GenServer.call(Client, :ping) do
            "PONG" -> :ok
            _      -> {:error, :no_connection_redis}
        end
    end

    def create_urls(urls) do
        with :ok <- check_connection() do
            datetime = DateTime.utc_now() |> DateTime.to_unix
            urls = urls
            |> Enum.map(&save_host(check_url(&1), datetime))
            GenServer.cast(Client, {:zadds, urls})
            :ok
        end
    end

    defp check_url(url) do
        host = Regex.run(~r/[a-z0-9-\.]+\.[a-z]{2,4}/, url)
        if is_nil(host) do
            %{host: nil}
        else
            %{host: List.first(host)}
        end
    end

    defp save_host(%{:host => host}, datetime) when not is_nil(host) do
        ["ZADD", "urls", 0, "#{datetime}:#{host}"]
    end

    defp save_host(_host, _attrs) do
        {:error, :incorrect_data}
    end

    def list_hosts(%{"from" => from, "to"=> to}) do
        with :ok <- check_connection(), 
        true <- is_numeric(from), true <- is_numeric(to),
        datetime_start <- String.to_integer(from),
        datetime_end <- String.to_integer(to) do
            hosts = GenServer.call(Client, {:zrange, datetime_start, datetime_end})
            |> Enum.map(&String.replace(&1, ~r/^\d*\:/, ""))
            |> Enum.uniq 
            {:ok, hosts}
        end 
    end

    def list_hosts(_attrs) do
        {:error, :incorrect_data}
    end

    defp is_numeric(str) do
        case Float.parse(str) do
        {_num, ""} -> true
        _          -> {:error, :incorrect_data}
        end
    end

end