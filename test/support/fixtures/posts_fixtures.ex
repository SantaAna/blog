defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: Faker.Lorem.sentence(),
        title: Faker.Lorem.sentence(),
        published_on: Faker.Date.between(Date.add(Date.utc_today, -30), Date.add(Date.utc_today, 30)),
        visible: Enum.random([true, false])
      })
      |> Blog.Posts.create_post()

    post
  end
end
