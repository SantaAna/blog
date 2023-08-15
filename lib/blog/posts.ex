defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post

  def search_by_title(title, preloads \\ [:user]) do
    search_string = "%#{title}%"

    match_query =
      from p in visible_posts_query(preloads),
        where: ilike(p.title, ^search_string)

    Repo.all(match_query)
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(preloads \\ [:user]) do
    Repo.all(visible_posts_query(preloads))
  end

  defp visible_posts_query(preloads \\ [:user]) do
    from p in Post,
      where: p.visible,
      where: p.published_on <= ^Date.utc_today(),
      order_by: [desc: p.published_on],
      preload: ^preloads
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id, preloads \\ []) do
    query =
      from p in Post,
        preload: ^preloads

    Repo.get!(query, id)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, tags \\ []) do
    %Post{}
    |> Post.changeset(attrs, tags)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(post, attrs, tags \\ [])
  def update_post(%Post{} = post, %{"cover_image" => %{"url" => ""}} = attrs, tags) do
    attrs = Map.put(attrs, "cover_image", nil)
    post
    |> Post.changeset(attrs, tags)
    |> Repo.update()
  end
  def update_post(%Post{} = post, attrs, tags) do
    post
    |> Post.changeset(attrs, tags)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}, tags \\ []) do
    Post.changeset(post, attrs, tags)
  end
end
