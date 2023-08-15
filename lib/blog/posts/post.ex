defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :title, :string
    field :visible, :boolean, default: true
    field :published_on, :date
    belongs_to :user, Blog.Accounts.User
    has_one :cover_image, Blog.CoverImages.CoverImage, on_replace: :delete
    has_many :comments, Blog.Comments.Comment
    many_to_many :tags, Blog.Tags.Tag, join_through: "posts_tags", on_replace: :delete

    timestamps()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any},
          any
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(post, attrs, tags \\ [])

  def changeset(post, attrs, tags) do
    post
    |> cast(attrs, [:title, :body, :visible, :published_on, :user_id])
    |> cast_assoc(:cover_image)
    |> validate_required([:title, :body, :user_id])
    |> unique_constraint(:title)
    |> foreign_key_constraint(:user_id)
    |> put_assoc(:tags, tags)
  end

end
