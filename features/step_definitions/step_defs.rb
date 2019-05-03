# frozen_string_literal: true

Given("a is {int}") do |num|
  @a = num
end

And("b is {int}") do |num|
  @b = num
end

When("I add a to b") do
  @c = @a + @b
end

Then("result is {int}") do |num|
  expect(@c).to eq(num)
end
