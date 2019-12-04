defmodule K8s.Cluster.Discovery do
  @moduledoc false

  @behaviour K8s.Cluster.Discovery.Driver

  @impl true
  def api_versions(_, _ \\ []), do: {:ok, []}

  @impl true
  def resource_definitions(_, _ \\ []), do: {:ok, []}

  @doc """
  Get all resources keyed by groupVersion/apiVersion membership.
  """
  @spec resources_by_group(atom(), Keyword.t() | nil) :: {:ok, map()} | {:error, atom()}
  def resources_by_group(cluster, opts \\ []) do
    {:ok, conn} = K8s.Cluster.conn(cluster)

    {:ok, versions} = K8s.default_driver().versions(conn, opts)

    r =
      Enum.reduce(versions, %{}, fn v, agg ->
        {:ok, resources} = K8s.default_driver().resources(v, conn, opts)

        list = Map.get(agg, v, [])
        upd_list = list ++ resources
        Map.put(agg, v, upd_list)
      end)

    {:ok, r}
  end
end
