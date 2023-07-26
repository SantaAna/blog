defmodule Blog.Repo.Migrations.UpdatePost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :sub_title
      add :visible, :boolean
      add :published_on, :date
    end
  end
end
