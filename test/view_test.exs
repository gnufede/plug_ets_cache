defmodule FakeController do
  use Phoenix.Controller
  use PhoenixEtsCache.View, false

  def index(conn, _params) do
    cache_and_render(conn, "index.txt", "text/plain", %{value: "cache"})
  end
end

defmodule FakeView, do: use Phoenix.View, root: "test/support"

defmodule PhoenixEtsCache.ViewTest do
  use ExUnit.Case, async: true
  use Plug.Test

  def action(controller, verb, action, headers \\ []) do
    conn = conn(verb, "/", headers) |> Plug.Conn.fetch_query_params
    controller.call(conn, controller.init(action))
  end

  test "caches the controller response" do
   conn = action(FakeController, :get, :index, ["content-type": "text/plain"])
   cached_resp = PhoenixEtsCache.Store.get(conn)

   assert conn.resp_body == "Hello cache\n"
   assert cached_resp.value == conn.resp_body
   assert cached_resp.type == "text/plain"
 end
end