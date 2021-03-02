defmodule Harmony.ServerView do
  require EEx

  @templates_path Path.expand("web/templates/servers", File.cwd!)

  EEx.function_from_file :def, :index, Path.join(@templates_path, "index.eex"), [:servers]
  EEx.function_from_file :def, :show, Path.join(@templates_path, "show.eex"), [:server]
end