defmodule HandlerTest do
  use ExUnit.Case, async: true

  import Harmony.Handler, only: [handle: 1]

  #  @tag :pending
  test "Handling requests to /servers path" do
    request = """
    GET /servers HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 305

    <h1>Available Servers:</h1>
    <br>
    <ul>
        \n<li>LearnElixir - Server to learn Elixir programming language</li>
        \n<li>LearnFlutter - Server to learn Flutter framework</li>
        \n<li>LearnPhoenix - Server to learn Phoenix framework</li>
        \n<li>LearnPostgresQL - Server to learn PostgresQL</li>\n    \n</ul>
    """
    assert Harmony.Handler.handle(request) == response
  end

  #  @tag :pending
  test "Handling request to specific server path" do
    url_index = Integer.to_string(Enum.random(1..3))
    request = """
    GET /servers/#{url_index} HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response_content = %{length: 0, body: ""}

    case url_index do
      "1" ->
        assert Harmony.Handler.handle(request) == prepare_response_content(
                 response_content,
                 "<h1>LearnFlutter</h1>\n<br>\n<h2>Server to learn Flutter framework</h2>"
               );
      "2" ->
        assert Harmony.Handler.handle(request) == prepare_response_content(
                 response_content,
                 "<h1>LearnElixir</h1>\n<br>\n<h2>Server to learn Elixir programming language</h2>"
               )
      "3" ->
        assert Harmony.Handler.handle(request) == prepare_response_content(
                 response_content,
                 "<h1>LearnPhoenix</h1>\n<br>\n<h2>Server to learn Phoenix framework</h2>"
               )
      "4" ->
        assert Harmony.Handler.handle(request) == prepare_response_content(
                 response_content,
                 "<h1>LearnPostgresQL</h1>\n<br>\n<h2>Server to learn PostgresQL</h2>"
               )
    end
  end

  #  @tag :pending
  test "Handling request for deleting specific server" do
    request = """
    DELETE /servers/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    body = "Insufficient user privileges to delete the server: LearnFlutter."

    response = """
    HTTP/1.1 403 Forbidden
    Content-Type: text/html
    Content-Length: #{byte_size(body)}

    #{body}
    """

    assert Harmony.Handler.handle(request) == response

  end

  #  @tag :pending
  test "Handling request to /home path" do
    request = """
    GET /home HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    body = """
    <h1>Available Servers:</h1>
    <br>
    <ul>
        \n<li>LearnElixir - Server to learn Elixir programming language</li>
        \n<li>LearnFlutter - Server to learn Flutter framework</li>
        \n<li>LearnPhoenix - Server to learn Phoenix framework</li>
        \n<li>LearnPostgresQL - Server to learn PostgresQL</li>\n    \n</ul>
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

  #  @tag :pending
  test "Handling rogue requests" do
    request = """
    GET /#{Faker.Lorem.word} HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
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

  #  @tag :pending
  test "Handling requests with ?= as its parameters" do
    request = """
    GET /servers?id=1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    body = "<h1>LearnFlutter</h1>\n<br>\n<h2>Server to learn Flutter framework</h2>"

    response = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: #{byte_size(body)}

    #{body}
    """

    assert Harmony.Handler.handle(request) == response
  end

  #  @tag :pending
  test "Handling request to open file about.html" do
    request = """
    GET /info/about HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
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

  #  @tag :pending
  test "Handling request to get the form to create a new harmony server" do
    request = """
    GET /servers/new HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
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

  #  @tag :pending
  test "Handling post request to create a new server" do
    request = """
    POST /servers HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=LearnPostGresQL&description=Server+to+learn+PostGresQL
    """

    response_body = "Created a new server called LearnPostGresQL\nDescription: Server to learn PostGresQL"

    response = """
    HTTP/1.1 201 Created
    Content-Type: text/html
    Content-Length: #{byte_size(response_body)}

    #{response_body}
    """

    assert handle(request) == response
  end

  #  @tag :pending
  test "Handling api request when user access /api/servers" do
    request = """
    GET /api/servers HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    body = """
           [{\"region\":\"asia\",\"name\":\"LearnFlutter\",\"join_link\":\"\",\"id\":1,\"description\":\"Server to learn Flutter framework\"},{\"region\":\"asia\",\"name\":\"LearnElixir\",\"join_link\":\"\",\"id\":2,\"description\":\"Server to learn Elixir programming language\"},{\"region\":\"asia\",\"name\":\"LearnPhoenix\",\"join_link\":\"\",\"id\":3,\"description\":\"Server to learn Phoenix framework\"},{\"region\":\"us-east\",\"name\":\"LearnPostgresQL\",\"join_link\":\"\",\"id\":4,\"description\":\"Server to learn PostgresQL\"}]
           """
           |> remove_trailing_whitespace

    response = """
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: #{byte_size(body)}

    #{body}
    """

    assert handle(request) == response
  end

  #  @tag :pending
  test "Handling api post request to /api/servers endpoint" do
    request = """
    POST /api/servers HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/json\r
    Content-Length: 21\r
    \r
    {"name": "LearnDevOps", "description": "Server to learn DevOps"}
    """

    body = "Server LearnDevOps/Server to learn DevOps created!"

    response = """
    HTTP/1.1 201 Created
    Content-Type: text/html
    Content-Length: #{byte_size(body)}

    #{body}
    """

    assert handle(request) == response
  end

  defp remove_trailing_whitespace(text) do
    String.slice(text, 0, String.length(text) - 1)
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
end