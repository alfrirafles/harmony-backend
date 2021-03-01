defmodule Harmony.Handler do

  @moduledoc """
  Handler for HTTP requests.
  """

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
  def route(%{method: "GET", path: "/servers/new", response_body: ""} = conversation) do
    @pages_path
    |> Path.join("register.html")
    |> File.read
    |> handle_file(conversation)
  end

  def route(%{method: "GET", path: "/info/" <> page, response_body: ""} = conversation) do
    @pages_path
    |> Path.join(page <> ".html")
    |> File.read
    |> handle_file(conversation)
  end

  def route(%{method: "GET", path: "/servers", response_body: ""} = conversation) do
    %{conversation | status: 200, response_body: "Available Servers:\nLearnFlutter, LearnElixir, LearnPhoenixFramework"}
  end

  def route(%{method: "GET", path: "/servers/" <> id, response_body: ""} = conversation) do
    case id do
      "1" -> %{conversation | status: 200, response_body: "Welcome to Learn Flutter Server!"}
      "2" -> %{conversation | status: 200, response_body: "Welcome to Learn Elixir Server!"}
      "3" -> %{conversation | status: 200, response_body: "Welcome to Learn Phoenix Framework Server!"}
      _ -> %{conversation | status: 404, response_body: "Server not found!"}
    end
  end

  def route(%{method: "DELETE", path: "/servers/" <> id, response_body: ""} = conversation) do
    %{conversation | status: 403, response_body: "Insufficient user privileges to delete the server."}
  end

  def route(%{path: path} = conversation) do
    %{conversation | status: 404, response_body: "Page not found."}
  end

  @doc """
  Format the response according to the parsed map.
  """
  def format_response(conversation) do
    """
    HTTP/1.1 #{conversation.status} #{status_reason(conversation.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conversation.response_body)}

    #{conversation.response_body}
    """
  end

  defp emojify(%{status: 200, response_body: body} = conversation) do
    %{conversation | response_body: "👍" <> body <> "👍"}
  end

  defp emojify(conversation), do: conversation

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

