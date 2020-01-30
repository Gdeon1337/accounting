defmodule Accounting.RedisSupervisor do
  use Supervisor
  alias Redix

  def start_link(redis_connection) do
    Supervisor.start_link(__MODULE__, redis_connection, name: __MODULE__)
  end

  def init(redis_connection) do
    children =
        for i <- 0..(Application.get_env(:accounting, :pool_size) - 1) do
            %{
              id: {Redix, i},
              start: {Redix, :start_link, [redis_connection, [name: :"redix_#{i}"]]}
            }
        end
    Supervisor.init(children, strategy: :one_for_one)
  end

  def zadds(value, datetime) do
      value = value
        |> Enum.map(fn domain -> ["ZADD", "urls", 0, "#{datetime}:#{domain}"] end)
      Redix.pipeline(:"redix_#{random_index()}", value)
  end


  def ping() do
      case Redix.command(:"redix_#{random_index()}", ["PING"]) do
          {:ok, "PONG"} -> :ok
          _      -> {:error, :no_connection_redis}
      end
  end

  def zrevrange_by_lex(datetime_start, datetime_end) do
      {:ok, values} = Redix.command(:"redix_#{random_index()}", ["ZREVRANGEBYLEX", "urls", "[#{datetime_end + 1}", "[#{datetime_start - 1}"])
      values
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), Application.get_env(:accounting, :pool_size) - 1)
  end
end