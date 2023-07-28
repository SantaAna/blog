defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :title, :string
    field :visible, :boolean, default: true
    field :published_on, :date
    has_many :comments, Blog.Comments.Comment

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :visible, :published_on])
    |> validate_required([:title, :body])
  end
end
