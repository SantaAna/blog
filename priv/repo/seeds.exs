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
alias Blog.Tags.Tag
alias Blog.Accounts.User

Faker.start()

user =
  Repo.insert!(%User{
    username: "shawn",
    password: "123456789012",
    email: "shawn@gmail.com",
    hashed_password: "123456789012"
  })

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
  tags = [:ready, :set, :go]
  tag = Enum.random(tags)

  post =
    Post.changeset(
      %Post{},
      %{
        user_id: user.id,
        title: title,
        body: body,
        visible: visible,
        published_on: date,
        tags: tag
      }
    )
    |> Repo.insert!()

  Comment.changeset(%Comment{}, %{
    content: Faker.Lorem.sentence(),
    post_id: post.id,
    user_id: user.id
  })
  |> Repo.insert!()
end

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
  tags = [:ready, :set, :go]
  tag = Enum.random(tags)

  post =
    Post.changeset(
      %Post{},
      %{
        title: title,
        body: body,
        visible: visible,
        published_on: date,
        tags: tag,
        user_id: user.id
      }
    )
    |> Repo.insert!()

  Comment.changeset(%Comment{}, %{
    content: Faker.Lorem.sentence(),
    post_id: post.id,
    user_id: user.id
  })
  |> Repo.insert!()
end
