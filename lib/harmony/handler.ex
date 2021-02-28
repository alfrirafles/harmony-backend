defmodule Harmony.Handler do
  def handle(request) do
    request
    |> parse
    |> route
    |> format_response
  end

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
    %{method: method, path: path, response_body: ""}
  end

  def route(%{method: "GET", path: "/servers", response_body: ""} = conversation) do
    %{method: conversation.method, path: conversation.path, response_body: "/Flutter\n /Discord\n"}
  end

  def route(%{method: "GET", response_body: ""} = conversation) do
    IO.puts "path not found!"
  end

  def format_response(conversation) do
    # Transformation:
    # Transform it into the following:
    expected_response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(conversation.response_body)}

    #{conversation.response_body}
    """
  end
end

