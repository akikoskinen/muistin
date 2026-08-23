defmodule MuistinWeb.Router do
  use MuistinWeb, :router

  import MuistinWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MuistinWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MuistinWeb do
    pipe_through :browser

    live "/", HomeLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", MuistinWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", MuistinWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MuistinWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", MuistinWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{MuistinWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
