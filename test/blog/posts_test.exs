defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures
    import Blog.CommentsFixtures

    @invalid_attrs %{body: nil, title: nil, subtitle: %{hello: "map"}}

    test "search_by_title/1 does not return visible: false posts" do
      post_fixture(%{visible: false})
      assert Posts.search_by_title("some title") == []
    end

    test "search_by_title/1 displays posts in order from newest to oldest" do
      today_post = post_fixture(%{published_on: Date.utc_today(), visible: true})

      yesterday_post =
        post_fixture(%{published_on: Date.add(Date.utc_today(), -1), visible: true})

      assert Posts.search_by_title("") == [today_post, yesterday_post]
    end

    test "search_by_title/1 does not display posts dated in the future" do
      post_fixture(%{published_on: Date.add(Date.utc_today(), 1)})
      assert Posts.search_by_title("some title") == []
    end

    test "search_by_title/1 returns empty list with no matches" do
      assert Posts.search_by_title("hello") == []
    end

    test "search_by_title/1 returns list with one element with one match" do
      match = post_fixture(%{title: "hello", published_on: Date.utc_today(), visible: true})
      post_fixture(%{title: "world", published_on: Date.utc_today(), visible: true})
      assert Posts.search_by_title("hello") == [match]
    end

    test "search_by_title/1 return multiple matches" do
      match1 = post_fixture(%{title: "hello", published_on: Date.utc_today(), visible: true})

      match2 =
        post_fixture(%{title: "hello world", published_on: Date.utc_today(), visible: true})

      post_fixture(%{title: "world", published_on: Date.utc_today(), visible: true})

      expected = [match1, match2]
      result = Posts.search_by_title("hello")

      assert Enum.sort(result) == Enum.sort(expected)
    end

    test "search_by_title/1 is case insensitive" do
      match1 = post_fixture(%{title: "HELLO", published_on: Date.utc_today(), visible: true})
      match2 = post_fixture(%{title: "HeLlO", published_on: Date.utc_today(), visible: true})

      expected = [match1, match2]
      result = Posts.search_by_title("hello")

      assert Enum.sort(result) == Enum.sort(expected)
    end

    test "list_posts/0 does not return visible: false posts" do
      post_fixture(%{visible: false})
      assert Posts.list_posts() == []
    end

    test "list_posts/0 displays posts in order from newest to oldest" do
      today_post = post_fixture(%{published_on: Date.utc_today(), visible: true})

      yesterday_post =
        post_fixture(%{published_on: Date.add(Date.utc_today(), -1), visible: true})

      assert Posts.list_posts() == [today_post, yesterday_post]
    end

    test "list_posts/0 does not display posts dated in the future" do
      post_fixture(%{published_on: Date.add(Date.utc_today(), 1)})
      assert Posts.list_posts() == []
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture(%{published_on: Date.utc_today(), visible: true})
      assert Posts.list_posts() == [post]
    end

    test "get_post!/2 returns the post with given id and no options" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "get_post!/2 returns the post with given id and comments" do
      post = post_fixture()
      comment = comment_fixture(%{post_id: post.id})
      assert Posts.get_post!(post.id, load_comments: true).comments == [comment]
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{body: "some body", title: "some title"}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.body == "some body"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{body: "some updated body", title: "some updated title"}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.body == "some updated body"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
