defmodule CreditApprovalApp.CalculatePoints do
  @points %{
    "paying_job" => 4,
    "consistent_12months" => 2,
    "own_house" => 2,
    "own_car" => 1,
    "additional_income" => 2
  }

  def get_points(details_input) do
    Enum.reduce(@points, 0, fn {field, score}, acc ->
      case Map.get(details_input, field) do
        "yes" -> acc + score
        _ -> acc
      end
    end)
  end
end
