# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Void.Repo.insert!(%Void.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Void.Accounts

Accounts.register_user(%{
  email: "test1@void.com",
  password: "SuperSecret!",
  sub: 10_101_010,
  email_verified: true,
  username: "johndoe",
  display_name: "John Doe",
  profile: "",
  picture: "https://avatars.githubusercontent.com/u/44910820?v=4"
})

Accounts.register_user(%{
  email: "test2@void.com",
  password: "SuperSecret!",
  sub: 20_202_020,
  email_verified: true,
  username: "janedoe",
  display_name: "Jane Doe",
  profile: "",
  picture: "https://avatars.githubusercontent.com/u/44910820?v=4"
})
