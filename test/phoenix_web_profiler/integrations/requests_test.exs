defmodule PhoenixWeb.Profiler.RequestsTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest
  alias PhoenixWeb.ProfilerTest.Endpoint
  alias PhoenixWeb.Profiler.Requests

  @endpoint Endpoint

  setup do
    {:ok, conn: build_conn()}
  end

  test "records debug profile for browser requests", %{conn: conn} do
    conn = get(conn, "/")

    assert [token] = Plug.Conn.get_resp_header(conn, "x-debug-token")

    assert [profile] = Requests.multi_get(token)

    %{
      dumped: [],
      host: "www.example.com",
      method: "GET",
      path_info: [],
      phoenix_action: :index,
      phoenix_controller: PhoenixWeb.ProfilerTest.PageController,
      phoenix_endpoint: PhoenixWeb.ProfilerTest.Endpoint,
      phoenix_router: PhoenixWeb.ProfilerTest.Router,
      phoenix_view: PhoenixWeb.ProfilerTest.PageView,
      status: 200
    } = profile

    assert Map.has_key?(profile, PhoenixWeb.Profiler.Request.session_key())
    assert profile.duration > 0
    assert profile.memory > 0
  end

  test "records debug profile for api requests", %{conn: conn} do
    conn = get(conn, "/api")

    assert [token] = Plug.Conn.get_resp_header(conn, "x-debug-token")

    assert [profile] = Requests.multi_get(token)

    %{
      dumped: [],
      host: "www.example.com",
      method: "GET",
      path_info: ["api"],
      phoenix_action: :index,
      phoenix_controller: PhoenixWeb.ProfilerTest.APIController,
      phoenix_endpoint: PhoenixWeb.ProfilerTest.Endpoint,
      phoenix_router: PhoenixWeb.ProfilerTest.Router,
      phoenix_view: PhoenixWeb.ProfilerTest.APIView,
      status: 200
    }

    refute Map.has_key?(profile, PhoenixWeb.Profiler.Request.session_key())
    assert profile.duration > 0
    assert profile.memory > 0
  end
end