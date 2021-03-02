defmodule Harmony.Region do

  alias Harmony.Server

  def list_servers do
        [
          %Server{id: 1, name: "LearnFlutter", description: "Server to learn Flutter framework", region: "asia"},
          %Server{id: 2, name: "LearnElixir", description: "Server to learn Elixir programming language", region: "asia"},
          %Server{id: 3, name: "LearnPhoenix", description: "Server to learn Phoenix framework", region: "asia"},
          %Server{id: 4, name: "LearnPostgresQL", description: "Server to learn PostgresQL", region: "us-east"}
        ]
  end
end