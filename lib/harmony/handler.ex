defmodule Harmony.Handler do
  def handle(request) do
    request
    |> parse
    |> log
    |> route
    |> format_response
  end

  def log(conv), do: IO.inspect conv

  def parse(request) do
    # Input Request:
    #    request = """
    #    GET /servers HTTP/1.1
    #    Host: example.com
    #    User-Agent: ExampleBrowser/1.0
    #    Accept: */*
    #
    #    """

    # Transformations:
    [method, path, _http_version] =
      request
      |> String.split("\n", trim: true)
      |> Enum.at(0) # alternatively List.first(list)
      |> String.split(" ")
    # Output:
    %{method: method, path: path, response_body: "", status: nil}
  end

  def route(%{method: "GET", path: "/servers", response_body: ""} = conversation) do
    %{conversation | status: 200, response_body: "LearnFlutter, LearnElixir, LearnPhoenixFramework"}
  end

  def route(%{method: "GET", path: "/servers/" <> id, response_body: ""} = conversation) do
    case id do
      "1" -> %{conversation | status: 200, response_body: "Welcome to Learn Flutter Server!"}
      "2" -> %{conversation | status: 200, response_body: "Welcome to Learn Elixir Server!"}
      "3" -> %{conversation | status: 200, response_body: "Welcome to Learn Phoenix Framework Server!"}
      _ -> %{conversation | status: 404, response_body: "Server not found!"}
    end

  end

  def route(%{method: "GET", path: _, response_body: ""} = conversation) do
    %{conversation | status: 404, response_body: "Page not found."}
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

