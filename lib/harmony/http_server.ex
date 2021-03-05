defmodule Harmony.HttpServer do
  def server do
    {:ok, l_socket} = :gen_tcp.listen(4000, [:binary, packet: 0, active: false])
    {:ok, socket} = :gen_tcp.accept(l_socket)
    {:ok, binary} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    binary
  end
end