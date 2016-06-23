defmodule Loadmaster.JobQueue do
  use GenServer

  defmodule State do
    defstruct jobs: nil, parallel_jobs: nil
  end

  def start_link do
    state = %State{jobs: :queue.new(), parallel_jobs: get_parallel_jobs}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def enqueue(job) do
    GenServer.call(__MODULE__, {:enqueue, job})
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({:enqueue, job}, _from, %{jobs: queue, parallel_jobs: parallel_jobs} = state) do
    %{active: active_workers} = Supervisor.count_children(Loadmaster.JobSupervisor)

    Loadmaster.GithubStatus.update(job, %{state: "pending", message: "Docker image build is running."})

    if active_workers >= parallel_jobs do
      state = %{state | jobs: :queue.in(job, queue)}
      {:reply, :queued, state}
    else
      start_job(job)
      {:reply, :started, state}
    end
  end

  def handle_info({:DOWN, _ref, _, _pid, :normal}, %{jobs: queue} = state) do
    case :queue.out(queue) do
      {{:value, job}, rest} ->
        start_job(job)
        {:noreply, %{state | jobs: rest}}
      {:empty, _} ->
        {:noreply, state}
    end
  end

  def handle_info({:DOWN, _ref, _, _, :noproc}, state), do: {:noreply, state}

  defp start_job(job) do
    {:ok, runner} = Supervisor.start_child(Loadmaster.JobSupervisor, [job])
    Process.monitor(runner)
  end

  defp get_parallel_jobs do
    case Integer.parse(Application.get_env(:loadmaster, :parallel_jobs) || "") do
      {i, ""} ->
        i
      _ ->
        1
    end
  end
end
