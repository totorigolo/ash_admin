defmodule AshAdmin.Components.TopNav.ActorSelect do
  @moduledoc false
  use Phoenix.Component

  import AshAdmin.Helpers

  attr :authorizing, :boolean, required: true
  attr :actor_paused, :boolean, required: true
  attr :actor, :any, required: true
  attr :actor_resources, :any, required: true
  attr :toggle_authorizing, :string, required: true
  attr :toggle_actor_paused, :string, required: true
  attr :clear_actor, :string, required: true
  attr :api, :any, required: true
  attr :actor_api, :any, required: true
  attr :prefix, :any, required: true

  def actor_select(assigns) do
    ~H"""
    <div id="actor-hook" class="flex items-center mr-5 text-white" phx-hook="Actor">
      <div>
        <span>
          <button phx-click={@toggle_authorizing} type="button px-2">
            <span :if={@authorizing}>(Authorizing)</span>
            <span :if={!@authorizing}>(Not authorizing)</span>
          </button>
          <button :if={@actor} phx-click={@toggle_actor_paused} type="button px-2">
            <span :if={@actor_paused}>(Unused)</span>
            <span :if={!@actor_paused}>(Used)</span>
          </button>
          <.link
            :if={@actor}
            class="hover:text-blue-400 hover:underline"
            target={"#{@prefix}?api=#{AshAdmin.Api.name(@actor_api)}&resource=#{AshAdmin.Resource.name(@actor.__struct__)}&tab=show&primary_key=#{encode_primary_key(@actor)}"}
          >
            <%= user_display(@actor) %>
          </.link>
          <button :if={@actor} phx-click={@clear_actor} type="button">
            <svg
              width="1em"
              height="1em"
              viewBox="0 0 16 16"
              fill="white"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"
              />
              <path
                fill-rule="evenodd"
                d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"
              />
            </svg>
          </button>
        </span>
      </div>
      <div :if={!@actor}>
        <%= render_actor_link(assigns, @actor_resources) %>
      </div>
    </div>
    """
  end

  defp render_actor_link(assigns, [{api, resource}]) do
    assigns = assign(assigns, api: api, resource: resource)

    ~H"""
    <.link navigate={"#{@prefix}?api=#{AshAdmin.Api.name(@api)}&resource=#{AshAdmin.Resource.name(@resource)}&action_type=read"}>
      Set <%= AshAdmin.Resource.name(@resource) %>
    </.link>
    """
  end

  defp render_actor_link(assigns, apis_and_resources) do
    assigns = assign(assigns, apis_and_resources: apis_and_resources)

    ~H"""
    <div aria-labelledby="actor-banner">
      <.link
        :for={{{api, resource}, i} <- Enum.with_index(@apis_and_resources)}
        navigate={"#{@prefix}?api=#{AshAdmin.Api.name(api)}&resource=#{AshAdmin.Resource.name(resource)}&action_type=read"}
      >
        Set <%= AshAdmin.Resource.name(resource) %>
        <span :if={i != Enum.count(@apis_and_resources) - 1}>
          |
        </span>
      </.link>
    </div>
    """
  end

  defp user_display(actor) do
    name = AshAdmin.Resource.name(actor.__struct__)

    case Ash.Resource.Info.primary_key(actor.__struct__) do
      [field] ->
        "#{name}: #{Map.get(actor, field)}"

      fields ->
        Enum.map_join(fields, ", ", fn field ->
          "#{field}: #{Map.get(actor, field)}"
        end)
    end
  end
end
