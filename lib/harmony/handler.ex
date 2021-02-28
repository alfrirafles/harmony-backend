defmodule Harmony.Handler do

  @moduledoc """
  Handler for HTTP requests.
  """


  require Logger

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
  Tracks HTTP requests that returns 404 for debugging purposes.
  """
  def track(%{status: 404, path: path} = conversation) do
    Logger.warn "Warning: User trying to access #{path}, where page not exists for such path."
    conversation
  end

  @doc """
  Captures any other request than 404, when calling track function.
  """
  def track(conversation), do: conversation

  @doc """
  Rewrite the path of the requests /home to /servers
  """
  def rewrite_path(%{path: "/home"} = conversation) do
    %{conversation | path: "/servers"}
  end

  @doc """
  Rewrite the path with the special syntaxes of '?=' into a standard url
  """
  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<slug>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  @doc """
  Capture any other path that doesnt contain '?='
  """
  def rewrite_path(conversation), do: conversation

  @doc """
  Updates the conversation's path according to the slug given by the rewrite_path function.
  """
  defp rewrite_path_captures(conversation, %{"slug" => slug, "id" => id}) do
    %{conversation | path: "/#{slug}/#{id}"}
  end

  @doc """
  Captures any other conversation that doesn't contain '?='
  """
  defp rewrite_path_captures(conversation, nil), do: conversation

  @doc """
  Logs the parsed request for debugging purposes.
  """
  def log(conv), do: IO.inspect conv

  @doc """
  Parses the request into a map that can be used for routing.
  """
  def parse(request) do
    [method, path, _http_version] =
      request
      |> String.split("\n", trim: true)
      |> Enum.at(0) # alternatively List.first(list)
      |> String.split(" ")
    %{method: method, path: path, response_body: "", status: nil}
  end

  @doc """
  Handling the route access to /server/new to open the html page register.html
  """
  def route(%{method: "GET", path: "/servers/new", response_body: ""} = conversation) do
    Path.expand("../../web/pages", __DIR__)
    |> Path.join("register.html")
    |> File.read
    |> handle_file(conversation)
  end

  @doc """
  Handling the route access to info/<page-name> to open the appropriate <page-name>.html page
  """
  def route(%{method: "GET", path: "/info/" <> page, response_body: ""} = conversation) do
    Path.expand("../../web/pages", __DIR__)
    |> Path.join(page <> ".html")
    |> File.read
    |> handle_file(conversation)
  end

  @doc """
  Handles the route access to /servers
  """
  def route(%{method: "GET", path: "/servers", response_body: ""} = conversation) do
    %{conversation | status: 200, response_body: "Available Servers:\nLearnFlutter, LearnElixir, LearnPhoenixFramework"}
  end

  @doc """
  Handles the route access to specific Harmony servers denoted by their id that is defined as string.
  """
  def route(%{method: "GET", path: "/servers/" <> id, response_body: ""} = conversation) do
    case id do
      "1" -> %{conversation | status: 200, response_body: "Welcome to Learn Flutter Server!"}
      "2" -> %{conversation | status: 200, response_body: "Welcome to Learn Elixir Server!"}
      "3" -> %{conversation | status: 200, response_body: "Welcome to Learn Phoenix Framework Server!"}
      _ -> %{conversation | status: 404, response_body: "Server not found!"}
    end
  end

  @doc """
  Handles the route access to /servers/id with the delete method.
  """
  def route(%{method: "DELETE", path: "/servers/" <> id, response_body: ""} = conversation) do
    %{conversation | status: 403, response_body: "Insufficient user privileges to delete the server."}
  end

  @doc """
  Handles accessing to non existing page in the server.
  """
  def route(%{path: path} = conversation) do
    %{conversation | status: 404, response_body: "Page not found."}
  end

  @doc """
  Update the map to contain the content of the requested page file.
  """
  def handle_file({:ok, file_content}, conversation) do
    %{conversation | status: 200, response_body: file_content}
  end

  @doc """
  Update the map for the case that the page file is not found in the server.
  """
  def handle_file({:error, :enoent}, conversation) do
    %{conversation | status: 404, response_body: "Page not found."}
  end

  @doc """
  Update the map for other cases where there is problems when opening the page.
  """
  def handle_file({:error, reason}, conversation) do
    %{conversation | status: 500, response_body: "Error on reading file. (#{reason})"}
  end

  @doc """
  Format the response according to the parsed map.
  """
  def format_response(conversation) do
    expected_response = """
    HTTP/1.1 #{conversation.status} #{status_reason(conversation.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conversation.response_body)}

    #{conversation.response_body}
    """
  end

  @doc """
  Function to add emojis to the response body of a request that has status code of 200.
  """
  defp emojify(%{status: 200, response_body: body} = conversation) do
    %{conversation | response_body: "👍" <> body <> "👍"}
  end

  @doc """
  Function to not add emojis to the response body for requests with status other than 200.
  """
  defp emojify(conversation), do: conversation

  @doc """
  Returns the string representation of the given status code.
  """
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

