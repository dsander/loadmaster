defmodule Huginnbuilder.Router do
  use Huginnbuilder.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Huginnbuilder.Auth, repo: Huginnbuilder.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Huginnbuilder do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, except: [:index]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/repositories", RepositoryController
  end

  # Other scopes may use custom stacks.
  scope "/api", Huginnbuilder do
    pipe_through :api
    post "/webhook/:token", WebhookController, :handle
  end
end
