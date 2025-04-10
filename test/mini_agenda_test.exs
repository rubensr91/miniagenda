defmodule MiniAgendaTest do
  use ExUnit.Case

  alias MiniAgenda

  setup do
    {:ok, pid} = MiniAgenda.start_link(%{})
    %{pid: pid}
  end

  test "adds a valid contact", _context do
    assert :ok == MiniAgenda.add_contact("Alice", "123-456", "alice@example.com")
    assert %{name: "Alice", phone: "123-456", email: "alice@example.com"} = MiniAgenda.get_contact("Alice")
  end

  test "prevents duplicate contacts", _context do
    assert :ok == MiniAgenda.add_contact("Bob", "234-567", "bob@example.com")
    assert {:error, "Contact already exists"} == MiniAgenda.add_contact("Bob", "234-567", "bob@example.com")
  end

  test "validates email format", _context do
    # Test invalid email (missing '@' or '.')
    assert {:error, "Invalid email"} == MiniAgenda.add_contact("Charlie", "345-678", "charlieexamplecom")
  end

  test "removes a contact", _context do
    assert :ok == MiniAgenda.add_contact("Dave", "456-789", "dave@example.com")
    assert :ok == MiniAgenda.remove_contact("Dave")
    assert {:error, "Contact not found"} == MiniAgenda.get_contact("Dave")
  end

  test "lists contacts sorted alphabetically", _context do
    :ok = MiniAgenda.add_contact("Charlie", "345-678", "charlie@example.com")
    :ok = MiniAgenda.add_contact("Alice", "123-456", "alice@example.com")
    :ok = MiniAgenda.add_contact("Bob", "234-567", "bob@example.com")

    contacts = MiniAgenda.list_contacts()
    names = Enum.map(contacts, & &1.name)
    assert names == ["Alice", "Bob", "Charlie"]
  end
end
