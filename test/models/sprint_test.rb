require 'test_helper'

class SprintTest < ActiveSupport::TestCase

  test "add burndown_data points" do
  	sprint = create(:sprint)
    assert_equal "[]", sprint.burndown_data_string
  	sprint.set_burndown_data!(0, 30)
  	assert_equal "[{0,30}]", sprint.burndown_data_string
    sprint.set_burndown_data!(1,25)
    assert_equal "[{0,30},{1,25}]", sprint.burndown_data_string
    sprint.set_burndown_data!(0,35)
    assert_equal "[{0,35},{1,25}]", sprint.burndown_data_string
  end

end
