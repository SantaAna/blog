defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Accounts
  alias Blog.Posts
  alias Blog.Tags
  alias Blog.Posts.Post
  alias Blog.Comments
  alias Blog.Comments.Comment

  plug :require_user_owns_post when action in [:edit, :update, :delete]

  def search(conn, %{"title" => title_query}) do
    user_id = Map.get(conn.assigns[:current_user] || %{}, :id)
    matches = Posts.search_by_title(title_query, [:user, :tags])
    render(conn, :search, title_query: title_query, matches: matches, user_id: user_id)
  end

  def search(conn, _params) do
    user_id = Map.get(conn.assigns[:current_user] || %{}, :id)
    render(conn, :search, title_query: nil, matches: [], user_id: user_id)
  end

  def index(conn, _params) do
    posts = Posts.list_posts()
    user_id = Map.get(conn.assigns[:current_user] || %{}, :id)

    changeset =
      if user_id do
        Posts.change_post(%Post{user_id: conn.assigns.current_user.id})
      else
        Posts.change_post(%Post{})
      end

    render(conn, :index, posts: posts, user_id: user_id, tag_names: "", changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{user_id: conn.assigns.current_user.id})
    render(conn, :new, changeset: changeset, tag_names: "")
  end

  @spec add_comment(Plug.Conn.t(), map) :: Plug.Conn.t()
  def add_comment(conn, %{"comment" => attr}) do
    Comments.create_comment(attr)
    show(conn, %{"id" => attr["post_id"]})
  end

  def delete_comment(conn, %{"id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)
    Comments.delete_comment(comment)
    show(conn, %{"id" => comment.post_id})
  end

  def create(conn, %{"post" => post_params}) do
    tags =
      post_params["tag_names"]
      |> String.split(",")
      |> Enum.reject(&(&1 == ""))
      |> Tags.create_tag_list()

    case Posts.create_post(post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, tag_names: "")
    end
  end

  def show(conn, %{"id" => id}) do
    user_id = Map.get(conn.assigns[:current_user] || %{}, :id)
    post = Posts.get_post!(id, [:user, :cover_image, comments: [:user]])
    IO.inspect(post.cover_image, label: "cover image for post")
    changeset = Comments.change_comment(%Comment{})
    render(conn, :show, post: post, changeset: changeset, user_id: user_id)
  end

  def edit(conn, %{"id" => id}) do
    user_id = conn.assigns[:current_user].id
    post = Posts.get_post!(id, [:tags, :cover_image])
    tag_names = Enum.map(post.tags, & &1.name) |> Enum.join(",")

    if user_id == post.user_id do
      changeset = Posts.change_post(post, %{}, post.tags)
      render(conn, :edit, post: post, changeset: changeset, tag_names: tag_names)
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: ~p"/posts")
      |> halt()
    end
  end

  # TODO something similar for comments
  defp require_user_owns_post(conn, _params) do
    post_id = String.to_integer(conn.path_params["id"])
    post = Posts.get_post!(post_id)

    if conn.assigns[:current_user].id == post.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: ~p"/posts")
      |> halt()
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id, [:tags])

    tags =
      post_params["tag_names"]
      |> String.split(",")
      |> Enum.reject(&(&1 == ""))
      |> Tags.create_tag_list()

    case Posts.update_post(post, post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end
end
