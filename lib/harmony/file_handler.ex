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

end