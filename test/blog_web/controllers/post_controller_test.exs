defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.CommentsFixtures
  import Blog.AccountsFixtures

  @create_attrs %{body: "some body", title: "some title"}
  @update_attrs %{body: "some updated body", title: "some updated title"}
  @invalid_attrs %{body: nil, title: nil}

  setup do
    {:ok, user_id: user_fixture().id}
  end

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end
  end

  describe "post/search" do
    test "renders page", %{conn: conn} do
      conn = get(conn, ~p"/posts/search")
      assert html_response(conn, 200) =~ "Hello, this is post"
    end

    test "renders query on page", %{conn: conn} do
      conn = get(conn, ~p"/posts/search", title: "wow")
      assert html_response(conn, 200) =~ "wow"
    end

    test "renders match on page", %{conn: conn, user_id: user_id} do
      post_fixture(%{
        title: "hello world",
        published_on: Date.utc_today(),
        visible: true,
        user_id: user_id
      })

      conn = get(conn, ~p"/posts/search", title: "hello")
      assert html_response(conn, 200) =~ "hello world"
    end

    test "does not render non-match on page", %{conn: conn, user_id: user_id} do
      post_fixture(%{title: "hello world", user_id: user_id})
      conn = get(conn, ~p"/posts/search", title: "blue")
      refute html_response(conn, 200) =~ "hello world"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      user = user_fixture(password: "HappyPuppy123")
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()
      conn = post(conn, ~p"/posts", post: %{body: "body", title: "title", user_id: user.id})

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "redirects unauthenticated user from form for editing chosen post", %{
      conn: conn,
      post: post
    } do
      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 302) =~ "redirect"
    end

    test "redirects user that does not own post", %{conn: conn} do
      not_owner = user_fixture()
      post = post_fixture(user_id: user_fixture().id)
      conn = log_in_user(conn, not_owner)
      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 302) =~ "redirect"
    end

    test "renders form for editing post if user is authenticated and owns post", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when no user is set", %{conn: conn, post: post} do
      conn = put(conn, ~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "redirects when non-owning user is set", %{conn: conn} do
      post = post_fixture(user_id: user_fixture().id)
      non_owner = user_fixture()

      conn =
        conn
        |> log_in_user(non_owner)
        |> put(~p"/posts/#{post}", post: @update_attrs)

      assert redirected_to(conn) == ~p"/posts"
    end

    test "redirects when user is valid", %{conn: conn} do
      owning_user = user_fixture()
      post = post_fixture(user_id: owning_user.id)

      conn =
        conn
        |> log_in_user(owning_user)
        |> put(~p"/posts/#{post}", post: @update_attrs)

      assert redirected_to(conn) == ~p"/posts/#{post}"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post} do
      conn = put(conn, ~p"/posts/#{post}", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "redirects with no logged in user, post not deleted", %{
      conn: conn,
      post: post
    } do
      conn = delete(conn, ~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/users/log_in"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ post.body
    end

    test "redirects with non-owner user, post not deleted", %{conn: conn} do
      non_owner = user_fixture()
      post = post_fixture(user_id: user_fixture().id)

      conn =
        conn
        |> log_in_user(non_owner)
        |> delete(~p"/posts/#{post}")

      assert redirected_to(conn) == ~p"/posts"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ post.body
    end

    test "deletes post with owner user, redirects to posts", %{conn: conn} do
      owner = user_fixture()
      post = post_fixture(user_id: owner.id)

      conn =
        conn
        |> log_in_user(owner)
        |> delete(~p"/posts/#{post}")

      assert redirected_to(conn) == ~p"/posts"
      assert_raise Ecto.NoResultsError, fn -> get(conn, ~p"/posts/#{post}") end
    end
  end

  describe "posts and comments" do
    setup [:create_post_with_comments]

    test "shows posts and comments", %{conn: conn, post: post, comment: comment} do
      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "comments"
      assert html_response(conn, 200) =~ comment.content
    end

    test "does not create comments on POST if not logged in, redirects", %{
      conn: conn,
      post: post,
      comment: existing_comment
    } do
      content = Faker.Lorem.sentence()

      conn =
        post(conn, ~p"/comments/", %{"comment" => %{"content" => content, "post_id" => post.id}})

      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "creates comment if user is logged in", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      content = Faker.Lorem.sentence()

      conn =
        conn
        |> log_in_user(user)
        |> post(~p"/comments/", %{"comment" => %{"content" => content, "post_id" => post.id}})

      # LEFT OFF HERE!
    end
  end

  defp create_post_with_comments(_) do
    user = user_fixture()
    post = post_fixture(%{user_id: user.id})
    comment = comment_fixture(%{post_id: post.id, user_id: user.id})

    %{
      post: post,
      comment: comment
    }
  end

  defp create_post(_) do
    user = user_fixture()
    post = post_fixture(%{user_id: user.id})
    %{post: post}
  end
end
