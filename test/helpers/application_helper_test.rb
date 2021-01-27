require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
	include ApplicationHelper 

	test "remove_from_order" do
		assert_equal("1,2,3,5", remove_from_order('1,2,3,4,5', '4'))		
	end

	test "remove_from_order_at_only" do
		assert_equal("", remove_from_order_at('1',0))
	end

	test "remove_from_order_end" do
		assert_equal "1,2,3,4", remove_from_order('1,2,3,4,5', '5')		
	end

	test "remove_from_order_start" do
		assert_equal "2,3,4,5", remove_from_order('1,2,3,4,5', '1')		
	end

	test "remove_from_order_missing" do
		assert_equal "1,2,3,4,5", remove_from_order('1,2,3,4,5', '6')		
	end

	test "remove_from_order_integer" do
		assert_equal "1,2,4,5", remove_from_order('1,2,3,4,5', 3)		
	end


	test "remove_from_order_at" do
		assert_equal "1,2,4,5", remove_from_order_at('1,2,3,4,5', 2)
	end

	test "remove_from_order_at_beginning" do
		assert_equal "2,3,4,5", remove_from_order_at('1,2,3,4,5', 0)
	end

	test "remove_from_order_at_end" do
		assert_equal "1,2,3,4", remove_from_order_at('1,2,3,4,5', 4)
	end


	test "append_to_order" do
		assert_equal "1,2,3,4,5,6", append_to_order("1,2,3,4,5", "6")
	end

	test "append_to_order_duplicate" do
		assert_equal "1,2,3,4,5", append_to_order("1,2,3,4,5", "2")
	end

	test "append_to_order_integer" do
		assert_equal "1,2,3,4,5,8", append_to_order("1,2,3,4,5", 8)
	end


	test "insert_into_order" do
		assert_equal "1,2,3,a,4,5", insert_into_order("1,2,3,4,5", "a", 3)
	end

	test "insert_into_order_beginning" do
		assert_equal "a,1,2,3,4,5", insert_into_order("1,2,3,4,5", "a", 0)
	end

	test "insert_into_order_end" do
		assert_equal "1,2,3,4,5,a", insert_into_order("1,2,3,4,5", "a", 5)
	end

	test "insert_into_order_empty_order" do
		assert_equal "a", insert_into_order("", "a", 0)
	end

	test "insert_into_order_integer" do
		assert_equal "1,2,3,8,4,5", insert_into_order("1,2,3,4,5", 8, 3)
	end
end