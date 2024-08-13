defmodule Void.Slugs do
  @phrase_generators [
    &Faker.Cannabis.buzzword/0,
    &Faker.Food.ingredient/0,
    &Faker.Team.creature/0,
    &Faker.Pizza.topping/0
  ]

  def generate do
    [fun] = Enum.take_random(@phrase_generators, 1)

    phrase = fun.()

    "#{Faker.Company.bullshit_prefix()}-#{phrase}-#{Faker.Company.bullshit_suffix()}"
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
  end
end
