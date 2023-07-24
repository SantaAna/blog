defmodule Blog.Repo.Migrations.AddSubTitleToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :sub_title, :text
    end
  end
end
