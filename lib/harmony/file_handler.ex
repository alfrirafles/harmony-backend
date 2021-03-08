defmodule Harmony.FileHandler do
  @moduledoc """
  Handle specific files to be returned as a response body to a request.
  """

  @doc """
  Update the map to contain the content of the requested page file.\n
  In case the page not found, returns "page not found" as the response body.\n
  In case any other problems exists, returns an error message with reason for debugging purposes.
  """
  def handle_file({:ok, file_content}, conversation) do
    {200, "text/html", file_content}
  end

  def handle_file({:error, :enoent}, conversation) do
    {404, "text/html", "Page not found."}
  end

  def handle_file({:error, reason}, conversation) do
    {500, "text/html", "Error on reading file. (#{reason})"}
  end

  def read_csv(source_path) do
    [header_line | data_lines] = source_path
                                 |> read_from_file
    headers = header_line
              |> String.split(";")
    Enum.reduce(
      data_lines,
      [],
      fn data, acc ->
        combined_items = data
                         |> String.split(";")
                         |> Enum.zip(headers)
                         |> Enum.map(fn {k, v} -> %{String.to_atom(v) => k} end)
                         |> Enum.reduce(%{}, &Map.merge/2)
        acc = [combined_items | acc]
      end
    )
  end

  def write_csv(source_path, addition) do
    [header | data_lines] = source_path |> read_from_file
    if Enum.count(data_lines) == 0 do
      new_content = Enum.join([header, addition], "\r\n")
      File.write(source_path, new_content)
      else
      new_content = [addition | data_lines] |> List.insert_at(0, header) |> Enum.join("\r\n")
      File.write(source_path, new_content)
    end
  end

  defp read_from_file(source_path) do
    {:ok, file_content} = source_path
                          |> File.read
    file_content |> String.split("\r\n")
  end

end