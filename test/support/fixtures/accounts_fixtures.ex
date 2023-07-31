defmodule Blog.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Accounts` context.
  """

  def unique_user_email,
    do: "#{Faker.Lorem.word()}#{System.unique_integer([:positive])}@example.com"

  def valid_user_password,
    do:
      "#{Faker.Lorem.word()}#{System.unique_integer([:positive])}"
      |> String.pad_trailing(12, "a")
      |> String.slice(0..Enum.random(11..20))

  def unique_username,
    do:
      "#{Faker.Lorem.word()}#{System.unique_integer([:positive])}"
      |> String.pad_trailing(4, "a")
      |> String.slice(0..Enum.random(3..19))

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      username: unique_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Blog.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
