# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Blog.Repo.insert!(%Blog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Blog.Repo
alias Blog.Posts.Post
Faker.start()

Enum.each(1..3, fn _ ->
  Post.changeset(
    %Post{},
    %{
      title: Faker.Lorem.Shakespeare.Ru.hamlet(),
      sub_title: Faker.Lorem.Shakespeare.Ru.king_richard_iii(),
      body: Faker.Lorem.Shakespeare.Ru.romeo_and_juliet()
    }
  )
  |> Repo.insert!()
end)

Enum.each(1..7, fn _ ->
  Post.changeset(
    %Post{},
    %{
      title: Faker.Lorem.sentence(),
      sub_title: Faker.Cat.name(),
      body: Faker.Lorem.paragraphs(3) |> Enum.join("\n")
    }
  )
  |> Repo.insert!()
end)
