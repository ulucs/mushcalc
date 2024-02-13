defmodule MushcalcWeb.Character.Equivalences do
  use MushcalcWeb, :live_component

  @eq_list_item %{"stat" => nil, "value" => nil}

  defp eqs_to_list(eqs) do
    Enum.map(eqs, fn {stat, value} -> %{"stat" => stat, "value" => value} end)
  end

  defp list_to_eqs(list) do
    Enum.map(list, fn %{"stat" => stat, "value" => value} -> {stat, value} end)
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:equivs, eqs_to_list(assigns.equivs))}
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:equivs, [@eq_list_item])
     |> assign(:stat_options,
       Strength: "str",
       Dexterity: "dex",
       Intelligence: "int",
       Luck: "luk",
       HP: "hp",
       MP: "mp",
       Attack: "atk",
       "Magic Attack": "matk",
       Defense: "def",
       "%All Stats": "as"
     )}
  end

  def send_equivs(socket) do
    send(self(), {:equivs_change, list_to_eqs(socket.assigns.equivs)})
    socket
  end

  @impl true
  def handle_event("add_char_eq_stat", _, socket) do
    {:noreply, update(socket, :equivs, &List.insert_at(&1, -1, @eq_list_item))}
  end

  def handle_event("remove_char_eq_stat", params, socket) do
    {:noreply, socket |> update(:equivs, &List.delete_at(&1, params["ix"])) |> send_equivs()}
  end

  def handle_event("stat_change", params, socket) do
    with {value, _} <- Float.parse(params["value"]) do
      {:noreply,
       socket
       |> update(
         :equivs,
         &List.update_at(&1, String.to_integer(params["nrow"]), fn _ ->
           %{"stat" => params["stat"], "value" => value}
         end)
       )
       |> send_equivs()}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.card title="Stat equivalences">
        <.form_table
          id="stat_eqs"
          rows={Enum.map(@equivs, &to_form/1)}
          phx_change={JS.push("stat_change", target: @myself)}
        >
          <:col :let={{stat, n}}>
            <.input
              type="select"
              name="stat"
              id={"stat_#{n}"}
              field={stat[:stat]}
              options={@stat_options}
            />
          </:col>
          <:col :let={{stat, n}}>
            <.input type="number" name="value" id={"value_#{n}"} field={stat[:value]} min={0} />
          </:col>
          <:action :let={{_, n}}>
            <span
              class="text-red-500 cursor-pointer hover:underline"
              phx-click={JS.push("remove_char_eq_stat", value: %{ix: n}, target: @myself)}
            >
              Remove
            </span>
          </:action>
        </.form_table>
        <div class="flex flex-row gap-4 w-full justify-end">
          <.button phx-click={JS.push("add_char_eq_stat", target: @myself)}>
            Add One More
          </.button>
        </div>
      </.card>
    </div>
    """
  end
end
