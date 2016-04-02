require "minitest/autorun"
require_relative "test_helper"

# @author Michael Telford
class TestLoad < Minitest::Test
    include TestHelper
    
    def setup
        # Runs before every test.
    end
    
    def test_load
        flunk_ex self do
            # TODO: Supress the load output.
            #assert load 'load.rb'
            raise LoadError, "TODO: test_load with suppressed output"
        end
    end
end
