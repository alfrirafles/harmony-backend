defmodule Harmony.Handler do

  @moduledoc """
  Handler for HTTP requests.
  """

  alias Harmony.Conversation
  alias Harmony.ServerController

  import Harmony.Plugins, only: [track: 1, rewrite_path: 1, log: 1]
  import Harmony.Parser, only: [parse: 1]
  import Harmony.FileHandler, only: [handle_file: 2]

  @pages_path Path.expand("web/pages", File.cwd!)

  @doc """
  Transforms HTTP request into response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  @doc """
  Handles routing for specific path in the request. Routes available:\n
  /servers/new - return the register.html file content\n
  /info/<page_name> - return <page_name>.html file content\n
  /servers - returns the list of available servers.\n
  /servers/id - returns specific server welcome page message.\n

  In any case the request contain path to unavailable page, returns 404.
  """
  def route(%Conversation{method: "GET", path: "/servers", response_body: ""} = conversation) do
    ServerController.index(conversation)
  end

  def route(%Conversation{method: "GET", path: "/down/" <> time_out, response_body: ""} = conversation) do
    ServerController.time_out(conversation)
  end

  def route(%Conversation{method: "GET", path: "/servers/new", response_body: ""} = conversation) do
    {status, content_type, body} = @pages_path
                                   |> Path.join("register.html")
                                   |> File.read
                                   |> handle_file(conversation)
    Conversation.format(body, [status: status, content_type: content_type, conversation: conversation])
  end

  def route(%Conversation{method: "GET", path: "/servers/" <> id, response_body: ""} = conversation) do
    params = Map.put(conversation.request_params, "id", id)
    ServerController.show(conversation, params)
  end

  def route(%Conversation{method: "POST", path: "/servers", request_params: params} = conversation) do
    ServerController.create(conversation, params)
  end

  def route(%Conversation{method: "POST", path: "/servers/" <> id, request_params: params} = conversation) do
    MessageController.create(conversation, params)
  end

  def route(%Conversation{method: "DELETE", path: "/servers/" <> id, response_body: ""} = conversation) do
    ServerController.delete(conversation, id)
  end

  def route(%Conversation{method: "GET", path: "/info/" <> page, response_body: ""} = conversation) do
    {status, content_type, body} = @pages_path
                                   |> Path.join(page <> ".html")
                                   |> File.read
                                   |> handle_file(conversation)
    Conversation.format(body, [status: status, content_type: content_type, conversation: conversation])
  end

  def route(%Conversation{method: "GET", path: "/api/servers", response_body: ""} = conversation) do
    Harmony.Api.ServerController.index(conversation)
  end

  def route(%Conversation{method: "POST", path: "/api/servers", response_body: ""} = conversation) do
    Harmony.Api.ServerController.create(conversation)
  end

  def route(%Conversation{path: _path} = conversation) do
    body = "Page not found."
           |> Conversation.format(status: 404, content_type: "text/html", conversation: conversation)
  end

  @doc """
  Format the response according to the parsed map.
  """
  def format_response(%Conversation{} = conversation) do
    """
    HTTP/1.1 #{Conversation.full_status(conversation)}
    #{format_response_headers(conversation)}

    #{conversation.response_body}
    """
  end

  def format_response_headers(conversation) do
    for {key, value} <- conversation.response_headers do
      "#{key}: #{value}"
    end
    |> Enum.sort
    |> Enum.reverse
    |> Enum.join("\n")
  end

  defp emojify(%Conversation{status: 200, response_body: body} = conversation) do
    %{conversation | response_body: "👍" <> body <> "👍"}
  end

  defp emojify(%Conversation{} = conversation), do: conversation
end

