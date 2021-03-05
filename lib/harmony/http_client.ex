defmodule Harmony.HttpClient do
  def client do
    some_host_in_net = 'localhost'
    {:ok, socket} = :gen_tcp.connect(some_host_in_net, 4000, [:binary, packet: 0])
    :ok = :gen_tcp.send(socket, "some data")
    :ok = :gen_tcp.close(socket)
  end
end