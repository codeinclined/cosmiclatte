local test = require "u-test.u-test"
local Vector = require "cosmiclatte.vector"

test.vector.create = function()
  -- Test that the create function returns a table
  test.is_table(Vector())

  test.is_table(Vector(1))
  test.is_table(Vector(4.7))

  test.is_table(Vector(14, 48))
  test.is_table(Vector(482.7, 10398.4))

  test.is_table(Vector(1, 2, 3))
  test.is_table(Vector(1.5, 2.7, 3.14))

  test.is_table(Vector(1, 2, 3, 4))
  test.is_table(Vector(4098.234, 138.99, 48.3, 0.9999999))
end

test.vector.access = function()
  local vec1 = Vector(1, 2, 3, 4)

  -- Check that the components of a vector are accessible and numbers
  test.is_number(vec1[1])
  test.equal(vec1[1], 1)

  test.is_number(vec1[2])
  test.equal(vec1[2], 2)

  test.is_number(vec1[3])
  test.equal(vec1[3], 3)

  test.is_number(vec1[4])
  test.equal(vec1[4], 4)

  -- Check the synonyms for the vector components
  test.is_number(vec1.x)
  test.is_number(vec1.y)
  test.is_number(vec1.z)
  test.is_number(vec1.w)

  test.is_number(vec1.r)
  test.is_number(vec1.g)
  test.is_number(vec1.b)
  test.is_number(vec1.a)
end



test.vector.equality = function()
  local vec1 = Vector(1, 2, 3, 4)
  local vec2 = Vector(1, 2, 3, 4)
  local vec3 = Vector(2, 1, 4, 3)

  test.is_true(vec1 == vec2)
  test.is_false(vec1 == vec3)
  test.is_true(vec2 ~= vec3)

  -- Ensure that relative vectors still test equal to world vectors
  vec1.basis = vec3
  test.is_true(vec1 == vec2)
end

test.vector.uniform = function()
  local result = Vector.uniform(4)
  local expected = Vector(0, 0, 0, 0)

  test.is_table(result)
  test.is_true(result == expected)

  result = Vector.uniform(4, 15)
  test.is_false(result == expected)
end

test.vector.clone = function()
  local vec1 = Vector(1, 2, 3, 4)

  test.is_true(vec1 == Vector.clone(vec1))
end

-- Arithmetic
do
  local vec1 = Vector(14.6, 13.7, 2.3)
  local vec2 = Vector(16, 37, 86)

  test.vector.scalar_mul = function()
    local result = vec1 * 10
    local expected = Vector(vec1.x * 10, vec1.y * 10, vec1.z * 10)
    test.is_true(result == expected)
    test.is_false(result == Vector(1, 2, 3))

    result = vec2 * 10
    expected = Vector(vec2.x * 10, vec2.y * 10, vec2.z * 10)
    test.is_true(result == expected)
    test.is_false(result == Vector(1, 2, 3))
  end

  test.vector.scalar_div = function()
    local result = vec1 / 10
    local expected = Vector(vec1.x / 10, vec1.y / 10, vec1.z / 10)
    test.is_true(result == expected)
    test.is_false(result == Vector(1, 2, 3))

    result = vec2 / 10
    expected = Vector(vec2.x / 10, vec2.y / 10, vec2.z / 10)
    test.is_true(result == expected)
    test.is_false(result == Vector(1, 2, 3))
  end

  test.vector.vector_mul = function()
    local result = vec1 * vec2
    local expected = Vector(vec1.x * vec2.x, vec1.y * vec2.y, vec1.z * vec2.z)

    test.is_true(result == expected)
  end

  test.vector.vector_div = function()
    local result = vec1 / vec2
    local expected = Vector(vec1.x / vec2.x, vec1.y / vec2.y, vec1.z / vec2.z)

    test.is_true(result == expected)
  end

  test.vector.vector_add = function()
    local result = vec1 + vec2
    local expected = Vector(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z)

    test.is_true(result == expected)
  end

  test.vector.vector_sub = function()
    local result = vec1 - vec2
    local expected = Vector(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z)

    test.is_true(result == expected)
  end
end

test.vector.mixed_dim_arith = function()
  local vec1 = Vector(13, 17)
  local vec2 = Vector(15, -47, -5, 14)

  local result = vec1 + vec2
  local expected = Vector(vec1.x + vec2.x, vec1.y + vec2.y, vec2.z, vec2.w)
  test.is_true(result == expected)

  result = vec1 - vec2
  expected = Vector(vec1.x - vec2.x, vec1.y - vec2.y, -vec2.z, -vec2.w)
  test.is_true(result == expected)

  result = vec1 * vec2
  expected = Vector(vec1.x * vec2.x, vec1.y * vec2.y, vec2.z, vec2.w)
  test.is_true(result == expected)

  result = vec1 / vec2
  expected = Vector(vec1.x / vec2.x, vec1.y / vec2.y)
  test.is_true(result == expected)

  result = vec2 / vec1
  expected = Vector(vec2.x / vec1.x, vec2.y / vec1.y, vec2.z, vec2.w)
  test.is_true(result == expected)
end

-- Vector math
do
  local vec1 = Vector(13, -18, 27)
  local vec2 = Vector(-7.4, 23.9, 44.4)

  test.vector.length = function()
    local result = Vector.length(vec1)
    local expected = math.sqrt(vec1.x^2 + vec1.y^2 + vec1.z^2)

    test.is_number(result)
    test.equal(result, expected)
  end

  test.vector.dot_product = function()
    local result = Vector.dot(vec1, vec2)
    local expected = vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z

    test.is_number(result)
    test.equal(result, expected)
  end

  test.vector.cross_product = function()
    local result = Vector.cross(vec1, vec2)
    local expected = Vector(
      vec1[2]*vec2[3] - vec1[3]*vec2[2],
      vec1[3]*vec2[1] - vec1[1]*vec2[3],
      vec1[1]*vec2[2] - vec1[2]*vec2[1]
    )

    test.is_table(result)
    test.is_true(result == expected)
  end
end

-- Transformations
do
  local vec1 = Vector(42, 84, -7)
  local vec2 = Vector(40, 23, 85)

  test.vector.world_transform = function()
    local result = Vector.world(vec1)
    test.is_true(result == vec1)

    local localVec = Vector.clone(vec2)
    localVec.basis = vec1

    local localToWorld = Vector.world(localVec)
    test.is_table(localToWorld)
    test.is_false(localToWorld == vec2)
    test.is_true(localToWorld == vec1 + vec2)
  end

  test.vector.relative_transform = function()
    local result = Vector.relative(vec1, vec2)

    test.is_table(result)
    test.is_true(result == vec1)
    test.is_true(Vector.world(result) == vec2 + vec1)
  end

  test.vector.snap_transform = function()
    local result = Vector.snap(vec1, vec2)

    test.is_table(result)
    test.is_false(result == vec1)
    test.is_true(result == vec1 - vec2)
  end
end

-- Misc.
test.vector.oop = function()
  local vec1 = Vector(1, 2, 3)
  local vec2 = Vector(3, 2, 1)
  local vec3 = Vector(4, 5, 6)

  test.is_true(Vector.clone(vec1) == vec1:clone())
  test.is_true(Vector.string(vec1) == vec1:string())

  test.is_true(Vector.set_relative(Vector.clone(vec1), vec2, vec3) ==
                 Vector.clone(vec1):set_relative(vec2, vec3))
  test.is_true(Vector.set_world(Vector.clone(vec1), vec2) ==
                 Vector.clone(vec1):set_world(vec2))

  test.is_true(Vector.dot(vec1, vec2) == vec1:dot(vec2))
  test.is_true(Vector.cross(vec1, vec2) == vec1:cross(vec2))
  test.is_true(Vector.length_squared(vec1) == vec1:length_squared())
  test.is_true(Vector.length(vec1) == vec1:length())
  test.is_true(Vector.normalize(vec1) == vec1:normalize())

  test.is_true(Vector.world(vec1) == vec1:world())
  test.is_true(Vector.relative(vec1, vec2) == vec1:relative(vec2))
  test.is_true(Vector.snap(vec1, vec2) == vec1:snap(vec2))
end

-- Summarize if we are not running in the full suite
if not CL_DEFER_TEST_SUMMARY then
  local ntests, nfailed = test.result()
  test.summary()
end
