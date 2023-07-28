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
alias Blog.Comments.Comment
Faker.start()

rus_post_list =
  for x <- 1..10 do
    title = "#{Faker.Lorem.Shakespeare.Ru.hamlet()} #{x}"

    date =
      cond do
        rem(x, 3) == 0 -> Faker.Date.forward(Enum.random(1..100))
        rem(x, 3) == 1 -> Faker.Date.backward(Enum.random(1..100))
        rem(x, 3) == 2 -> Date.utc_today()
      end

    body = Faker.Lorem.Shakespeare.Ru.romeo_and_juliet()

    visible = rem(x, 2) == 0

    %{title: title, body: body, visible: visible, published_on: date}
  end

en_post_list =
  for x <- 1..10 do
    title = "#{Faker.Lorem.Shakespeare.En.hamlet()} #{x}"

    date =
      cond do
        rem(x, 3) == 0 -> Faker.Date.forward(Enum.random(1..100))
        rem(x, 3) == 1 -> Faker.Date.backward(Enum.random(1..100))
        rem(x, 3) == 2 -> Date.utc_today()
      end

    body = Faker.Lorem.paragraphs(3) |> Enum.join("\n")
    visible = rem(x, 2) == 0
    %{title: title, body: body, visible: visible, published_on: date}
  end

Enum.each(rus_post_list, fn post_data ->
  post =
    Post.changeset(
      %Post{},
      post_data
    )
    |> Repo.insert!()

  Comment.changeset(%Comment{}, %{content: Faker.Lorem.sentence(), post_id: post.id})
  |> Repo.insert!()
end)

Enum.each(en_post_list, fn post_data ->
  post =
    Post.changeset(
      %Post{},
      post_data
    )
    |> Repo.insert!()

  Comment.changeset(%Comment{}, %{content: Faker.Lorem.sentence(), post_id: post.id})
  |> Repo.insert!()
end)
