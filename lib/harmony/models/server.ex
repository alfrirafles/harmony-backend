defmodule Harmony.Server do
  defstruct [id: nil, name: "", description: "", region: "", join_link: ""]

  import Harmony.FileHandler, only: [read_csv: 1]

  @messages_source_path Path.expand("db/data", File.cwd!)

  def asia_region(server) do
    server.region == "asia"
  end

  def order_by_name_asc(server1, server2) do
    server1.name < server2.name
  end

  def order_by_id_asc(server1, server2) do
    server1.id < server2.id
  end

  def get_messages(server_id) do
    @messages_source_path
    |> Path.join("messages.csv")
    |> read_csv
    |> Enum.filter(&(&1.server_id == server_id))
  end
end