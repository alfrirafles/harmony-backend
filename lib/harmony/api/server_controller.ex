defmodule Harmony.Api.ServerController do

  alias Harmony.Region

  @content_type "application/json"

  def index(conversation) do
    json = Region.list_servers |> Poison.encode!
    %{conversation | status: 200, response_headers: %{"Content-Type" => "application/json", "Content-Length" => byte_size(json)}, response_body: json}
  end
end