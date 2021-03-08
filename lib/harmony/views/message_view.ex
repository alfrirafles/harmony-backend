defmodule Harmony.MessageView do
  require EEx

  @templates_path Path.expand("web/templates/servers", File.cwd!)

  EEx.function_from_file :def, :create, Path.join(@templates_path, "show.eex"), [:messages, :server]
end