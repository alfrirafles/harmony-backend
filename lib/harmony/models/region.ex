defmodule Harmony.Region do

  alias Harmony.Server

  @source_path Path.expand("db", File.cwd!)

  def list_servers do
    {:ok, content} = @source_path
                     |> Path.join("servers.json")
                     |> File.read
    %{"servers" => server_list} = content
                                  |> Poison.decode!
    server_list
    Enum.reduce(server_list, [],
      fn servers, acc ->
        %{id: id, name: name, description: description, region: region} =
          for {key, value} <- servers, into: %{}, do: {String.to_atom(key), value}
        [%Server{id: id, name: name, description: description, region: region} | acc]
      end)
  end

  def get_server(id) when is_integer(id) do
    match_server_id = &(&1.id == id)
    Enum.find(list_servers, match_server_id)
  end

  def get_server(id) when is_binary(id) do
    id
    |> String.to_integer
    |> get_server
  end
end