defmodule Loadmaster.BuildView do
  use Loadmaster.Web, :view

  def step_status(%{"state" => "success"}), do: "panel-success"
  def step_status(%{"state" => "running"}), do: "panel-warning"
  def step_status(%{"state" => "error"}), do: "panel-danger"
  def step_status(%{"state" => _}), do: "panel-default"
end
