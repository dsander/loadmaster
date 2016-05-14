defmodule Loadmaster.TestExecutor do
  def spawn_shell(_cmd, [in: :receive, out: {:send, pid}, err: {:send, _pid}]) do
    %Porcelain.Process{pid: pid}
  end
end
