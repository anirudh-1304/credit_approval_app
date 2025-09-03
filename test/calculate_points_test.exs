defmodule CreditApprovalApp.CalculatePointsTest do
  use ExUnit.Case

  alias CreditApprovalApp.CalculatePoints

  test "Should calculate exact points" do
    assert 7 ==
             CalculatePoints.get_points(%{
               "paying_job" => "yes",
               "consistent_12months" => "yes",
               "own_house" => "no",
               "own_car" => "yes",
               "additional_income" => "no"
             })
  end
end
