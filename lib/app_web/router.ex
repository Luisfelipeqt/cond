defmodule AppWeb.Router do
  use AppWeb, :router

  import AppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{AppWeb.UserAuth, :mount_current_scope}] do
      live "/", PublicLive.Home.Index
      live "/blog", PublicLive.Blog.Index
      live "/blog/:slug", PublicLive.Blog.Show
      live "/para-voce", PublicLive.Pages.ForYou
      live "/para-seu-negocio", PublicLive.Pages.ForBusiness
      live "/sobre-nos", PublicLive.Pages.About
      live "/privacidade", PublicLive.Pages.Privacy
      live "/termos", PublicLive.Pages.Terms
      live "/seguranca", PublicLive.Pages.Security
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AppWeb do
    pipe_through [:browser, :require_authenticated_user]

    # Autenticado mas sem exigir onboarding completo
    live_session :require_authenticated_user,
      on_mount: [{AppWeb.UserAuth, :require_authenticated}] do
      live "/onboarding", OnboardingLive.Index, :index
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    # Autenticado + onboarding concluído
    live_session :require_onboarded,
      on_mount: [
        {AppWeb.UserAuth, :require_authenticated},
        {AppWeb.UserAuth, :require_onboarding}
      ] do
      # Condomínios
      live "/condominios", AppLive.Condominios.Index, :index
      live "/condominios/novo", AppLive.Condominios.Index, :new

      # Assembleias & Atas (aninhadas sob condomínio)
      live "/condominios/:condo_id/assembleias", AppLive.Assembleias.Index, :index
      live "/condominios/:condo_id/assembleias/nova", AppLive.Assembleias.Index, :new
      live "/condominios/:condo_id/assembleias/:id", AppLive.Assembleias.Show, :show

      # Membros da organização (apenas administradoras)
      live "/organizacao/membros", AppLive.OrgMembers.Index, :index
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", AppWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{AppWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
