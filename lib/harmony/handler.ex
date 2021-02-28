defmodule Harmony.Handler do
  require Logger

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
#    |> emojify
    |> format_response
  end

  def track(%{status: 404, path: path} = conversation) do
    Logger.warn "Warning: User trying to access #{path}, where page not exists for such path."
    conversation
  end

  def track(conversation), do: conversation

  def rewrite_path(%{path: "/home"} = conversation) do
    %{conversation | path: "/servers"}
  end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<slug>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(conversation), do: conversation

  def rewrite_path_captures(conversation, %{"slug" => slug, "id" => id}) do
    %{conversation | path: "/#{slug}/#{id}"}
  end

  def rewrite_path_captures(conversation, nil), do: conversation

  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _http_version] =
      request
      |> String.split("\n", trim: true)
      |> Enum.at(0) # alternatively List.first(list)
      |> String.split(" ")
    %{method: method, path: path, response_body: "", status: nil}
  end

  def route(%{method: "GET", path: "/about", response_body: ""} = conversation) do
    Path.expand("../../web/pages", __DIR__)
    |> Path.join("about.html")
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

  def handle_file({:ok, file_content}, conversation) do
    %{conversation | status: 200, response_body: file_content}
  end

  def handle_file({:error, :enoent}, conversation) do
    %{conversation | status: 404, response_body: "Page not found."}
  end

  def handle_file({:error, reason}, conversation) do
    %{conversation | status: 500, response_body: "Error on reading file. (#{reason})"}
  end

  def format_response(conversation) do
    # Transformation:
    # Transform it into the following:
    expected_response = """
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

