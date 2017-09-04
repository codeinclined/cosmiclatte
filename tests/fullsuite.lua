local test = require "u-test.u-test"

CL_DEFER_TEST_SUMMARY = true

function include_test(test_module)
  print(string.format(
          "\n== %s %s", test_module, string.rep("=", 75 - #test_module)))
  require(test_module)
end

include_test("tests.vector_test")

local ntests, nfailed = test.result()
test.summary()
