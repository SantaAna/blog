defmodule Blog.CommentsTest do
  use Blog.DataCase

  alias Blog.Comments

  describe "comments" do
    alias Blog.Comments.Comment

    import Blog.CommentsFixtures
    import Blog.PostsFixtures
    import Blog.AccountsFixtures

    @invalid_attrs %{content: nil}

    setup do
      {:ok, user_id: user_fixture().id}
    end

    test "list_comments/0 returns all comments", state do
      today_post = post_fixture(%{user_id: state[:user_id]})
      comment = comment_fixture(%{post_id: today_post.id, user_id: state[:user_id]})
      assert Comments.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id", state do
      today_post = post_fixture(%{user_id: state[:user_id]})
      comment = comment_fixture(%{post_id: today_post.id, user_id: state[:user_id]})
      assert Comments.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment", state do
      today_post = post_fixture(%{user_id: state[:user_id]})
      valid_attrs = %{content: "some content", post_id: today_post.id, user_id: state[:user_id]}

      assert {:ok, %Comment{} = comment} = Comments.create_comment(valid_attrs)
      assert comment.content == "some content"
    end

    test "create_comment/1 with invalid data returns error changeset", state do
      assert {:error, %Ecto.Changeset{}} = Comments.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment", state do
      today_post = post_fixture(%{user_id: state[:user_id]})
      comment = comment_fixture(%{post_id: today_post.id, user_id: state[:user_id]})
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Comments.update_comment(comment, update_attrs)
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset", state do
      today_post = post_fixture(%{user_id: state[:user_id]})
      comment = comment_fixture(%{post_id: today_post.id, user_id: state[:user_id]})
      assert {:error, %Ecto.Changeset{}} = Comments.update_comment(comment, @invalid_attrs)
      assert comment == Comments.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment", state do
      today_post = post_fixture(%{user_id: state[:user_id]})
      comment = comment_fixture(%{post_id: today_post.id, user_id: state[:user_id]})
      assert {:ok, %Comment{}} = Comments.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Comments.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset", state do
      today_post = post_fixture(%{user_id: state[:user_id]})
      comment = comment_fixture(%{post_id: today_post.id, user_id: state[:user_id]})
      assert %Ecto.Changeset{} = Comments.change_comment(comment)
    end
  end
end
