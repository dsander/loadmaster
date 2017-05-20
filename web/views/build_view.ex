defmodule Loadmaster.BuildView do
  use Loadmaster.Web, :view

  def step_status(%{"state" => "success"}), do: "panel-success"
  def step_status(%{"state" => "running"}), do: "panel-warning"
  def step_status(%{"state" => "error"}), do: "panel-danger"
  def step_status(_), do: "panel-default"

  def duration(%Loadmaster.Job{data: %{"finished_at" => finished_at, "started_at" => started_at}}) do
    dur = finished_at - started_at
    seconds = rem(dur, 60)
    minutes = (dur - seconds) / 60
    to_human(minutes, seconds)
  end

  def duration(_), do: ""

  def to_human(minutes, seconds) when minutes > 0 do
    " (#{Float.to_string(minutes, [decimals: 0])} min #{seconds} sec)"
  end

  def to_human(_, seconds) do
    " (#{seconds} sec)"
  end
end
