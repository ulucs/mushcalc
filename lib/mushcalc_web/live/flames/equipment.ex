defmodule MushcalcWeb.FlamesLive.Equipment do
  use MushcalcWeb, :live_component
  import Mushcalc.Flames.Utils

  @eq_slots [
    Hat: "hat",
    Top: "top",
    Bottom: "bottom",
    Shoes: "shoes",
    Gloves: "gloves",
    Cape: "cape",
    Shoulder: "shoulder",
    "Face Accessory": "face",
    "Eye Accessory": "eye",
    Earring: "ear",
    Pendant: "pendant",
    Ring: "ring",
    Belt: "belt",
    Pocket: "pocket"
  ]

  @empty_eq %{
    "slot" => nil,
    "level" => 150
  }

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:equips, [])
     |> assign(:eq_slots, @eq_slots)}
  end

  defp parse_val(nil, t, ek), do: parse_val("", t, ek)

  defp parse_val(val, "level", _) do
    case Integer.parse(val) do
      {v, _} -> v
      :error -> 150
    end
  end

  defp parse_val(val, target, equiv_keys) do
    if target in equiv_keys do
      case Float.parse(val) do
        {v, _} -> v
        :error -> 0.0
      end
    else
      val
    end
  end

  @impl true
  def handle_event("eqs_change", params, socket) do
    {n, _} = Integer.parse(params["nrow"])
    [target] = params["_target"]

    num_keys = Enum.map(socket.assigns.equivs, &elem(&1, 0))

    socket =
      update(
        socket,
        :equips,
        &List.update_at(&1, n, fn equip ->
          equip
          |> Map.put(target, parse_val(params[target], target, num_keys))
          |> Map.drop(["results"])
        end)
      )

    send(self(), {:equip_change, socket.assigns.equips})

    {:noreply, socket}
  end

  def handle_event("add_char_equip", _, socket) do
    {:noreply,
     socket
     |> update(:equips, &List.insert_at(&1, -1, @empty_eq))}
  end

  attr :class, :any, default: nil
  attr :equivs, :list, default: []

  @impl true
  def render(assigns) do
    ~H"""
    <div class={@class}>
      <.card title="Character Equipment">
        <.form_table
          id="equipments"
          rows={Enum.map(@equips, &to_form/1)}
          header={true}
          phx_change={JS.push("eqs_change", target: @myself)}
        >
          <:col :let={{eqf, n}} label="Slot">
            <.input type="select" id={"slot_#{n}"} name="slot" field={eqf[:slot]} options={@eq_slots} />
          </:col>
          <:col :let={{eqf, n}} label="Level">
            <.input type="number" id={"level_#{n}"} name="level" field={eqf[:level]} />
          </:col>
          <:col :let={{eqf, n}} :for={{stat, _} <- @equivs} label={stat}>
            <.input type="text" id={"flame_#{stat}_#{n}"} name={stat} field={eqf[stat]} />
          </:col>
          <:col :let={{eqf, _}} label="Score">
            <%= calc_score(@equivs, eqf.source) %>
          </:col>
          <:col :let={{eqf, _}} label="Pr(Better)">
            <%= eqf.source["results"] && Float.round(eqf.source["results"].probability * 100, 4) %>%
          </:col>
          <:col :let={{eqf, _}} label="Exp. Score">
            <%= eqf.source["results"] && Float.round(eqf.source["results"].expected_score, 1) %>
          </:col>
          <:col :let={{eqf, _}} label="ROI">
            <%= eqf.source["results"] && Float.round(eqf.source["results"].roi, 4) %>
          </:col>
        </.form_table>
        <div class="flex flex-row gap-4 w-full justify-end">
          <.button phx-click={JS.push("add_char_equip", target: @myself)}>
            Add One More
          </.button>
        </div>
      </.card>
    </div>
    """
  end
end
