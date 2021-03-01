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
    %{conversation | status: 200, response_body: file_content}
  end

  def handle_file({:error, :enoent}, conversation) do
    %{conversation | status: 404, response_body: "Page not found."}
  end

  def handle_file({:error, reason}, conversation) do
    %{conversation | status: 500, response_body: "Error on reading file. (#{reason})"}
  end

end