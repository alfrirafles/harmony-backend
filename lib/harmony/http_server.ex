defmodule Harmony.HttpServer do
  #  def server do
  #    {:ok, l_socket} = :gen_tcp.listen(4000, [:binary, packet: 0, active: false])
  #    {:ok, socket} = :gen_tcp.accept(l_socket)
  #    {:ok, binary} = :gen_tcp.recv(socket, 0)
  #    :ok = :gen_tcp.close(socket)
  #    binary
  #  end

  def start(port) when is_integer(port) and port > 1023 do
    IO.puts "🎧 Listening for connection request on port #{port}..."
    {:ok, listen_socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])
    accept_loop(listen_socket)
  end

  def accept_loop(listen_socket) do
    IO.puts "⌛️ Waiting to accept connection...\n"

    {:ok, client_socket} = :gen_tcp.accept(l_socket)

    IO.puts "👌 Connection accepted!\n"

    serve(client_socket)

    accept_loop(listen_socket)
  end

  def serve(client_socket) do
    client_socket
    |> read_request
    |> generate_response
    |> write_response(client_socket)
  end
end