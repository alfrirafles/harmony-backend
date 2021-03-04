defmodule Harmony.Server do
  defstruct [id: nil, name: "", description: "", region: ""]

  def asia_region(server) do
    server.region == "asia"
  end

  def order_by_name_asc(server1, server2) do
    server1.name < server2.name
  end
end