
defmodule Blog.CoverImages do
  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.CoverImages.CoverImage

  def create_cover_image(attrs \\ %{}) do
    %CoverImage{}
    |> CoverImage.changeset(attrs)
    |> Repo.insert()
  end

  def get_cover_image!(id) do
    Repo.get!(CoverImage, id)
  end

  def update_cover_image(%CoverImage{} = cover_image, attrs) do
      cover_image
      |> CoverImage.changeset(attrs)
      |> Repo.insert()
  end

  def delete_cover_image(%CoverImage{} = cover_image) do
    Repo.delete(cover_image)
  end
end
