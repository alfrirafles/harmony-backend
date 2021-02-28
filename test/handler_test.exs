defmodule HandlerTest do
  use ExUnit.Case

  alias Harmony.Handler

  test "Handling requests to /servers path" do
    request = """
    GET /servers HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 67

    Available Servers:
    LearnFlutter, LearnElixir, LearnPhoenixFramework
    """
    assert Harmony.Handler.handle(request) == response
  end

  test "Handling request to specific server path" do
    url_index = Integer.to_string(Enum.random(1..3))
    request = """
    GET /servers/#{url_index} HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response_content = %{length: 0, body: ""}

    case url_index do
      "1" ->
        assert Harmony.Handler.handle(request) == prepare_response_content(
                 response_content,
                 "Welcome to Learn Flutter Server!"
               );
      "2" ->
        assert Harmony.Handler.handle(request) == prepare_response_content(
                 response_content,
                 "Welcome to Learn Elixir Server!"
               )
      "3" ->
        assert Harmony.Handler.handle(request) == prepare_response_content(
                 response_content,
                 "Welcome to Learn Phoenix Framework Server!"
               )
    end
  end

  test "Handling request for deleting specific server" do
    request = """
    DELETE /servers/1 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = """
    HTTP/1.1 403 Forbidden
    Content-Type: text/html
    Content-Length: 50

    Insufficient user privileges to delete the server.
    """

    assert Harmony.Handler.handle(request) == response

  end

  defp prepare_response_content(response_content, body) when is_map(response_content) do
    response_content = %{response_content | body: body, length: String.length(body)}
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{response_content.length}

    #{response_content.body}
    """
  end

  test "Handling request to /home path" do
    request = """
    GET /home HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 67

    Available Servers:
    LearnFlutter, LearnElixir, LearnPhoenixFramework
    """

    assert Harmony.Handler.handle(request) == response
  end

  test "Handling for requests that have a rouge path" do
    request = """
    GET /test HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    body = "Page not found."

    response = """
    HTTP/1.1 404 Not Found
    Content-Type: text/html
    Content-Length: #{String.length(body)}

    #{body}
    """

    assert Harmony.Handler.handle(request) == response
  end

  test "Handling requests with ?= as its parameters" do
    request = """
    GET /servers?id=1 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    body = "Welcome to Learn Flutter Server!"

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{String.length(body)}

    #{body}
    """

    assert Harmony.Handler.handle(request) == response
  end
end