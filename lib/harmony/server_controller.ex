defmodule Harmony.ServerController do

  alias Harmony.Server

  def index(conversation) do
    %{conversation | status: 200, response_body: "Available Servers:\nLearnFlutter, LearnElixir, LearnPhoenixFramework"}
  end

  def show(conversation, %{"id" => id} = params) do
    case id do
      "1" -> %{conversation | status: 200, response_body: "Welcome to Learn Flutter Server!"}
      "2" -> %{conversation | status: 200, response_body: "Welcome to Learn Elixir Server!"}
      "3" -> %{conversation | status: 200, response_body: "Welcome to Learn Phoenix Framework Server!"}
      _ -> %{conversation | status: 404, response_body: "Server not found!"}
    end
  end

  def create(conversation, %{"name" => name, "description" => description} = server) do
    %{
      conversation |
      status: 201,
      response_body: "Created a new server called #{name}\nDescription: #{description}"
    }
  end

  def delete(conversation, server_id) do
    %{conversation | status: 403, response_body: "Insufficient user privileges to delete the server."}
  end
end