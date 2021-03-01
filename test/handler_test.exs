defmodule HandlerTest do
  use ExUnit.Case

  import Harmony.Handler
  import Harmony.Parser, only: [parse: 1]
  alias Harmony.Conversation

  @tag :pending
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

  @tag :pending
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

  @tag :pending
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
    response_content = %{response_content | body: body, length: byte_size(body)}
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{response_content.length}

    #{response_content.body}
    """
  end

  @tag :pending
  test "Handling request to /home path" do
    request = """
    GET /home HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    body = """
    Available Servers:
    LearnFlutter, LearnElixir, LearnPhoenixFramework
    """

    body = String.slice(body, 0, String.length(body) - 1)

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{byte_size(body)}

    #{body}
    """

    assert Harmony.Handler.handle(request) == response
  end

  @tag :pending
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
    Content-Length: #{byte_size(body)}

    #{body}
    """

    assert Harmony.Handler.handle(request) == response
  end

  @tag :pending
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
    Content-Length: #{byte_size(body)}

    #{body}
    """

    assert Harmony.Handler.handle(request) == response
  end

  @tag :pending
  test "Request to open file about.html" do
    request = """
    GET /info/about HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    {:ok, page_content} = Path.expand("../web/pages", __DIR__)
                          |> Path.join("about.html")
                          |> File.read

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{byte_size(page_content)}

    #{page_content}
    """

    assert handle(request) == response
  end

  @tag :pending
  test "Handlings request to get the form to create a new harmony server" do
    request = """
    GET /servers/new HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    {:ok, response_body} = Path.expand("../web/pages", __DIR__)
                           |> Path.join("register.html")
                           |> File.read

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{byte_size(response_body)}

    #{response_body}
    """

    assert handle(request) == response
  end

  test "Handling post request to create a new server" do
    request = """
    POST /servers HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    name=LearnPostGresQL&description=Server+to+learn+PostGresQL
    """

    response_body = "Created a new server called LearnPostGresQL\n
                      Description: Server to learn PostGresQL"

    response = """
    HTTP/1.1 201 Created
    Content-Type: text/html
    Content-Length: #{byte_size(response_body)}

    #{response_body}
    """

    assert handle(request) == response
  end
end