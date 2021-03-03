defmodule Harmony.Api.ServerController do

  alias Harmony.Region

  @content_type "application/json"

  def index(conversation) do
    json = Region.list_servers |> Poison.encode!
    %{conversation | status: 200, content_type: @content_type, response_body: json}
  end
end