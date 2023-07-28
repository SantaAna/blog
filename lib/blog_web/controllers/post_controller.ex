defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Comments
  alias Blog.Comments.Comment

  def search(conn, %{"title" => title_query}) do
    matches = Posts.search_by_title(title_query)
    render(conn, :search, title_query: title_query, matches: matches)
  end

  def search(conn, _params) do
    render(conn, :search, title_query: nil, matches: [])
  end

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, :new, changeset: changeset)
  end

  def add_comment(conn, %{"comment" => %{"content" => content, "post_id" => post_id}}) do
    Comments.create_comment(%{content: content, post_id: post_id})
    show(conn, %{"id" => post_id})
  end

  def delete_comment(conn, %{"id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)
    Comments.delete_comment(comment)
    show(conn, %{"id" => comment.post_id})
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id, load_comments: true)
    changeset = Comments.change_comment(%Comment{})
    render(conn, :show, post: post, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, :edit, post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
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
