defmodule Loadmaster.Router do
  use Loadmaster.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Loadmaster.Auth, repo: Loadmaster.Repo
    plug Loadmaster.Turbolinks
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Loadmaster do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, except: [:index, :show]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/repositories", RepositoryController do
      resources "images", ImageController, except: [:show]
      resources "builds", BuildController, only: [:index, :show]
      post "/builds/:id/run", BuildController, :run
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", Loadmaster do
    pipe_through :api
    post "/webhook/:token", WebhookController, :handle
  end
end
