require File.dirname(__FILE__) + '/../test_helper'
require 'revisions_controller'

# Re-raise errors caught by the controller.
class RevisionsController; def rescue_action(e) raise e end; end

class RevisionsControllerTest < Test::Unit::TestCase
  def setup
    @controller = RevisionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
