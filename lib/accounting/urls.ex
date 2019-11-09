defmodule Accounting.Urls do
    alias Exredis.Api, as: Client

    def check_connection() do
        case Client.ping do
            "PONG" -> :ok
            _      -> {:error, :no_connection_redis}
        end
    end

    def create_urls(urls) do
        with :ok <- check_connection() do
            datetime = DateTime.utc_now() |> DateTime.to_unix
            urls
            |> Enum.each(&save_host(check_url(&1), datetime))
            :ok
        end
    end

    def check_url(url) do
        host = Regex.run(~r/[a-z0-9-\.]+\.[a-z]{2,4}/, url) 
        if is_nil(host) do
            %{host: nil}
        else
            %{host: List.first(host)}
        end
    end

    def save_host(%{:host => host}, datetime) when not is_nil(host) do
        Client.lpush(datetime, host)
    end

    def save_host(_host, _attrs) do
        {:error, :incorrect_data}
    end

    def list_hosts(%{"from" => from, "to"=> to}) do
        with :ok <- check_connection(), 
        true <- is_numeric(from), true <- is_numeric(to),
        {:ok, datetime_start} <- DateTime.from_unix(String.to_integer(from), :second, Calendar.ISO),
        {:ok, datetime_end} <- DateTime.from_unix(String.to_integer(to), :second, Calendar.ISO) do
            hosts = Client.keys("*")
            |> Enum.filter(fn time -> is_numeric(time) == true end)
            |> Enum.filter(fn time -> String.to_integer(time) >= DateTime.to_unix(datetime_start) and String.to_integer(time) <= DateTime.to_unix(datetime_end) end)
            |> Enum.reduce([],fn time, acc ->  List.flatten([get_host(time) | acc]) end)
            |> Enum.uniq 
            {:ok, hosts}
        end 
    end

    def list_hosts(_attrs) do
        {:error, :incorrect_data}
    end

    def is_numeric(str) do
        case Float.parse(str) do
        {_num, ""} -> true
        _          -> {:error, :incorrect_data}
        end
    end

    def get_host(key_redis) do
        Client.lrange(key_redis, 0, Client.llen(key_redis))
    end

    
end