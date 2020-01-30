defmodule Accounting.Urls do
    alias Accounting.RedisSupervisor, as: Client
    require Logger


    def create_urls(urls) do
        with :ok <- Client.ping() do
            datetime = DateTime.utc_now() |> DateTime.to_unix
            urls = urls
            |> Enum.map(&check_url(&1))
            |> Enum.filter(fn domain -> not is_nil(domain) end)
            {status, _} = Client.zadds(urls, datetime)
            status
        end
    end

    defp check_url(url) do
        host = Regex.run(~r/([a-zA-Z0-9]([a-zA-Z0-9\-]{0,65}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}/, url)
        if not is_nil(host) do
            List.first(host)
        end
    end

    def list_hosts(from, to) do
        with :ok <- Client.ping(), 
        true <- is_numeric(from), true <- is_numeric(to),
        datetime_start <- String.to_integer(from),
        datetime_end <- String.to_integer(to) do
            hosts = Client.zrevrange_by_lex(datetime_start, datetime_end)
            |> Enum.map(&String.replace(&1, ~r/^\d*\:/, ""))
            |> Enum.uniq 
            {:ok, hosts}
        end 
    end

    defp is_numeric(str) do
        case Float.parse(str) do
        {_num, ""} -> true
        _          -> {:error, :incorrect_data}
        end
    end

end