defmodule Harmony.HttpServer do
  @moduledoc """
  Http Server module that uses :gen_tcp Erlang module
  """

  import Harmony.Handler, only: [handle: 1]

  @doc """
  Starts the server on the given `port` of localhost
  """
  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    IO.puts "🎧 Listening for connection request on port #{port}..."
    accept_loop(listen_socket)
  end

  @doc """
  Accept client connections on the `listen_socket`
  """
  def accept_loop(listen_socket) do
    IO.puts "⌛️ Waiting to accept connection...\n"
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    IO.puts "👌 Connection accepted!\n"
    pid = spawn(fn -> serve(client_socket) end)
    :ok = :gen_tcp.controlling_process(client_socket, pid)
    accept_loop(listen_socket)
  end

  @doc """
  Process the received request from the socket and
  sends back a response to to the client over the
  same socket.
  """
  def serve(client_socket) do
    IO.puts "Processing request on #{inspect self()}"
    client_socket
    |> read_request
    |> handle
    |> write_response(client_socket)
  end

  @doc """
  Receive a request on the client socket.
  """
  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)

    IO.puts "✅ Received request: \n"
    request
  end

  @doc """
  Send the response back to the client via the socket.
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts "✉️ Sent response:\n"
    IO.puts response
    :ok = :gen_tcp.close(client_socket)
  end
end