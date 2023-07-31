defmodule Blog.Repo.Migrations.AddUsername do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :text
    end

    create unique_index(:users, [:username])

    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    alter table(:comments) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
