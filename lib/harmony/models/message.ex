defmodule Harmony.Message do
  defstruct [server: nil, message: "", sender: "", created_at: nil]

  @data_source_path Path.expand("db/data", File.cwd!) |> Path.join("messages.csv")

  def order_by_date_created(message1, message2) do
    message1.created_at < message2.created_at
  end

  def append(server_id, message, sender) do
      timezone = Harmony.Timezone.utc_plus_7()
      date_time = Enum.join([timezone.date, timezone.time], " ")
      addition = Enum.join([server_id, message, sender, date_time], ";")
      Harmony.FileHandler.write_csv(@data_source_path, addition)
  end
end