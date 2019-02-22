defmodule SpoofWeb.Router do
  use SpoofWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpoofWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpoofWeb do
  #   pipe_through :api
  # end

  scope "/api/v1", SpoofWeb do
    pipe_through :api
    post "/spoof", SpoofController, :create
  end
end
