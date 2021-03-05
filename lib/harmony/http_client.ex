defmodule Harmony.HttpClient do

  def send_request(host, port, request) when is_list(host) and is_integer(port) and port > 1023 do
    host
    |> connect(port)
    |> pass_request(request)
    |> get_response
    |> format_response
  end

  def connect(host, port) do
    {:ok, socket} = :gen_tcp.connect(host, port, [:binary, packet: :raw, active: false])
    IO.puts "🆗 Connected to #{host}!"
    socket
  end

  def pass_request(socket, request) do
    IO.puts "✉️ Sent request:"
    IO.puts request
    :ok = :gen_tcp.send(socket, request)
    socket
  end

  def get_response(socket) do
    {:ok, response} = :gen_tcp.recv(socket, 0)
    IO.puts "📬 Received response from server:"
    IO.puts response
    :ok = :gen_tcp.close(socket)
    response
  end

  def format_response(_response) do
    "Successfully sent request and receive response from server!"
  end
end