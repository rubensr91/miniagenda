defmodule MiniAgenda do
  use GenServer

  # Client API

  @doc """
  Starts the MiniAgenda GenServer with an empty state.
  """
  @spec start_link(map()) :: GenServer.on_start()
  def start_link(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  @doc """
  Adds a contact with name, phone, and email.
  Returns :ok or {:error, reason}.
  """
  @spec add_contact(String.t(), String.t(), String.t()) :: :ok | {:error, String.t()}
  def add_contact(name, phone, email) do
    GenServer.call(__MODULE__, {:add_contact, name, phone, email})
  end

  @doc """
  Removes a contact by name.
  Returns :ok or {:error, reason}.
  """
  @spec remove_contact(String.t()) :: :ok | {:error, String.t()}
  def remove_contact(name) do
    GenServer.call(__MODULE__, {:remove_contact, name})
  end

  @doc """
  Retrieves a contact by name.
  Returns the contact map or {:error, "Contact not found"}.
  """
  @spec get_contact(String.t()) :: map() | {:error, String.t()}
  def get_contact(name) do
    GenServer.call(__MODULE__, {:get_contact, name})
  end

  @doc """
  Lists all contacts ordered alphabetically by name.
  """
  @spec list_contacts() :: [map()]
  def list_contacts() do
    GenServer.call(__MODULE__, :list_contacts)
  end

  # Server Callbacks

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call({:add_contact, name, phone, email}, _from, state) do
    cond do
      Map.has_key?(state, name) ->
        {:reply, {:error, "Contact already exists"}, state}

      not EmailValidator.valid?(email) ->
        {:reply, {:error, "Invalid email"}, state}

      true ->
        new_state = Map.put(state, name, %{name: name, phone: phone, email: email})
        {:reply, :ok, new_state}
    end
  end

  def handle_call({:remove_contact, name}, _from, state) do
    if Map.has_key?(state, name) do
      new_state = Map.delete(state, name)
      {:reply, :ok, new_state}
    else
      {:reply, {:error, "Contact not found"}, state}
    end
  end

  def handle_call({:get_contact, name}, _from, state) do
    normalized = String.upcase(name)

    result =
      state
      |> Map.values()
      |> Enum.find(fn contact -> String.upcase(contact.name) == normalized end)

    if result do
      {:reply, result, state}
    else
      {:reply, {:error, "Contact not found"}, state}
    end
  end


  def handle_call(:list_contacts, _from, state) do
    contacts =
      state
      |> Map.values()
      |> Enum.sort_by(&(&1.name))
    {:reply, contacts, state}
  end
end
