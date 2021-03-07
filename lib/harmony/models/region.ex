defmodule Harmony.Region do

  alias Harmony.Server
  import Harmony.FileHandler, only: [read_csv: 1]

  @embedded_source_path Path.expand("db/data", File.cwd!)
  @json_source_path Path.expand("db/json", File.cwd!)

  def list_servers(source: "file") do
    data_list = @embedded_source_path
                |> Path.join("servers.csv")
                |> read_csv
    for %{id: id, name: name, description: description, region: region, join_link: join_link} <- data_list,
        do: %Server{id: id, name: name, description: description, region: region, join_link: join_link}
  end

  def list_servers(source: "json") do
    {:ok, content} = @json_source_path
                     |> Path.join("servers.json")
                     |> File.read
    %{"servers" => server_list} = content
                                  |> Poison.decode!
    server_list
    Enum.reduce(
      server_list,
      [],
      fn servers, acc ->
        %{id: id, name: name, description: description, region: region} =
          for {key, value} <- servers, into: %{}, do: {String.to_atom(key), value}
        [%Server{id: id, name: name, description: description, region: region} | acc]
      end
    )
  end

  def get_server(id) when is_integer(id) do
    match_server_id = &(&1.id == id)
    Enum.find(list_servers(source: "json"), match_server_id)
  end

  def get_server(id) when is_binary(id) do
    id
    |> String.to_integer
    |> get_server
  end
end