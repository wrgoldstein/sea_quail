defmodule SeaQuailWeb.Router do
  use SeaQuailWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug(Guardian.Plug.Pipeline,
      module: SeaQuailWeb.Guardian,
      error_handler: SeaQuailWeb.AuthErrorHandler
    )

    plug(Guardian.Plug.VerifySession)
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource, allow_blank: true)
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(Guardian.Plug.Pipeline,
      module: SeaQuailWeb.Guardian,
      error_handler: SeaQuailWeb.AuthErrorHandler
    )

    plug(Guardian.Plug.VerifySession)
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource, allow_blank: false)
  end

  pipeline :ensure_authed_access do
    plug(:browser)
    plug(Guardian.Plug.LoadResource, allow_blank: false)
  end

  scope "/", SeaQuailWeb do
    pipe_through(:browser)
    get("/", PageController, :index)
    get("/login", SessionController, :index)
    post("/login", SessionController, :login)
    delete("/logout", SessionController, :logout)
    resources("/users", UserController, except: [:index, :delete, :show])
    get("/connection/edit", ConnectionController, :edit)
    put("/connection/edit", ConnectionController, :update)
    post("/connection/edit", ConnectionController, :update)
  end

  scope "/api", SeaQuailWeb do
    pipe_through(:api)
    post("/run", EditorController, :run)
  end
end
