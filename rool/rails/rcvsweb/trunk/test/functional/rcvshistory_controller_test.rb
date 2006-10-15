require File.dirname(__FILE__) + '/../test_helper'
require 'rcvshistory_controller'

# Re-raise errors caught by the controller.
class RcvshistoryController; def rescue_action(e) raise e end; end

class RcvshistoryControllerTest < Test::Unit::TestCase
  def setup
    @controller = RcvshistoryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
