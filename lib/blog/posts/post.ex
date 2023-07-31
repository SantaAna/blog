defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :title, :string
    field :visible, :boolean, default: true
    field :published_on, :date
    belongs_to :user, Blog.Accounts.User
    has_many :comments, Blog.Comments.Comment

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :visible, :published_on, :user_id])
    |> validate_required([:title, :body, :user_id])
  end
end
