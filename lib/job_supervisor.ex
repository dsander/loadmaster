defmodule Loadmaster.JobSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def init(state) do
    supervise([worker(Loadmaster.JobRunner, [], [restart: :temporary, function: :start_link])],
              [strategy: :simple_one_for_one,
               max_restarts: 5,
               max_seconds: 5])
  end
end
