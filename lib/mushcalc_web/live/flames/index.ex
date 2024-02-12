defmodule MushcalcWeb.FlamesLive.Index do
  alias Mushcalc.Persistence
  use MushcalcWeb, :live_view
  import Mushcalc.Flames.Scores
  import Mushcalc.Flames.Utils

  alias MushcalcWeb.Character
  alias MushcalcWeb.FlamesLive

  @base_equivs %{
    "int" => 1.0,
    "matk" => 3.0,
    "as" => 8.0
  }

  @method_opts [
    "Eternal / Rainbow": "eternal",
    "Powerful / Red": "powerful"
  ]

  defp with_results(equip, equiv, method) do
    Map.put(
      equip,
      "results",
      get_improvement_stats(
        %{
          type: :armor,
          level: equip["level"],
          score: calc_score(equiv, equip)
        },
        Map.new(equiv),
        method
      )
    )
  end

  defp parse_flame(flame) do
    case flame do
      "eternal" -> :eternal
      "powerful" -> :powerful
    end
  end

  defp debounce_recalc(socket) do
    if socket.assigns[:recalc_timer],
      do: Process.cancel_timer(socket.assigns.recalc_timer)

    assign(socket, :recalc_timer, Process.send_after(self(), :recalc, 200))
  end

  defp deserialize_assigns(data) do
    %{
      equivs: data["equivs"] || @base_equivs,
      equips:
        Enum.map(data["equips"] || [], fn equip ->
          Map.update(
            equip,
            "results",
            nil,
            &%{
              probability: &1["probability"],
              roi: &1["roi"],
              expected_score: &1["expected_score"]
            }
          )
        end)
    }
  end

  defp serialize_assigns(assigns) do
    %{"equivs" => assigns.equivs, "equips" => assigns.equips}
  end

  @impl true
  def mount(%{"user_id" => uid}, _, socket) do
    saved_data = Persistence.get_page_data(uid, "flames")

    {:ok,
     socket
     |> assign(:user_id, uid)
     |> assign(:method, :eternal)
     |> assign(:method_opts, @method_opts)
     |> assign(deserialize_assigns(saved_data || %{}))}
  end

  def mount(_, _, socket) do
    {:ok,
     socket
     |> push_navigate(to: "/flames?user_id=#{Ecto.UUID.generate()}")}
  end

  @impl true
  def handle_event("set_flame", params, socket) do
    {:noreply,
     socket
     |> assign(:method, parse_flame(params["flame"]))
     |> update(:equips, fn eqs -> Enum.map(eqs, &Map.drop(&1, ["results", "roi"])) end)
     |> debounce_recalc()}
  end

  @impl true
  def handle_info({:equivs_change, new_equivs}, socket) do
    {:noreply,
     socket
     |> assign(:equivs, new_equivs)
     |> update(:equips, fn eqs -> Enum.map(eqs, &Map.drop(&1, ["results", "roi"])) end)
     |> debounce_recalc()}
  end

  def handle_info({:equip_change, new_equips}, socket) do
    {:noreply, socket |> assign(:equips, new_equips) |> debounce_recalc()}
  end

  def handle_info(:recalc, socket) do
    {:noreply,
     socket
     |> update(
       :equips,
       &Enum.map(&1, fn eq ->
         if eq["results"],
           do: eq,
           else: with_results(eq, socket.assigns.equivs, socket.assigns.method)
       end)
     )}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def terminate(reason, socket) do
    Persistence.save_page_data(
      socket.assigns.user_id,
      "flames",
      serialize_assigns(socket.assigns)
    )

    reason
  end
end
