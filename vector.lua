--[[

  vector.lua
  Generic lua-based vectors of any dimension

  This module provides Lua (LuaGIT version planned) functions for vectors of
  any number of dimensions. This module uses a prototype-based interface
  rather than OOP.

  Returned vectors are simply tables with a metatable for
  arithmetic operations. Each component of vectors are indexed from 1 to
  remain consistent with the Lua standard libraries. The __index metamethod will
  translate requests to "x", "y", "z", "w" and "r", "g", "b", "a" to their
  respective indexes, therefore it may be faster to refer to the coordinates by
  index rather than by component name.

  If the "basis" property is set on a vector to another vector, then the vector
  will be interpreted as being relative to that vector. Vectors can be converted
  back and forth between world and local coordinates using Vector.world,
  Vector.relative, Vector.set_world, Vector.set_relative, and Vector.snap.

================================================================================
  Metamethods:

  __index(vec, i) --> number
      Translates coordinate or color components to numeric indexes to retrieve
      those components' values.

  __add(a, b) --> vector(table)
  __sub(a, b) --> vector(table)
  __mul(a, b) --> vector(table)
  __div(a, b) --> vector(table)
      Performs a component-wise arithmetic operation between two vectors or a
      scalar (__mul and __div). The resultant vector assumes the dimensions of
      the highest-dimension vector, except for __div which always uses a.

================================================================================
  Conversion Functions:

  Vector.string(vec) --> string
      Returns a string representation of vec. The output will display whether
      the vector is in world or local coordinates along with the component
      values enclosed in '<' and '>' characters.

          Examples: "Local Vector < -0.680414 0.272166 0.680414 >"
                    "World Vector < 2 -5 17 >"

================================================================================
  Setter Functions:

  Vector.set_relative(vector, newVector, basis)
      Sets vector to equal a copy of newVector relative to the passed basis
      vector. Coordinates are taken absolutely without transformation.

  Vector.set_relative(vector, newVector)
      Sets vector to equal a copy of newVector maintaining vector's basis.
      Coordinates are taken absolutely without transformation.

  Vector.set_world(vector, newVector)
      Sets vector to equal a copy of newVector in absolute world coordinates
      without performing any transformations. Discards basis if present.

================================================================================
  Vector Math Functions:

  Vector.dot(a, b) --> number
      Performs the dot product of two vectors of equal dimension.

  Vector.cross(a, b) --> vector(table)
      Performs the cross product of two three-dimensional vectors.

  Vector.length_squared(vec) --> number
      Finds the squared length of the passed vector. Prefer this over
      Vector.length when performing comparisons between variables as it skips a
      square root calculation.

  Vector.length(vec) --> number
      Finds the length of the passed vector. Prefer Vector.length_squared if
      being used for comparing two vectors, as this function incurs a square
      root calculation.

  Vector.normalize(vec) --> vector(table)
      Normalizes the passed vector to a unit vector pointing in the same
      direction. Cacheing this value when a vector does not change may be
      beneficial to performance.

================================================================================
  Transformation Functions:

  Vector.world(relativeVector) --> vector(table)
      Recursively transforms the passed vector based on its basis vector or
      simply return a copy of the passed variable if it was already in world
      coordinates.

  Vector.relative(basis, worldVector) --> vector(table)
      Returns a copy of the passed worldVector as a vector relative to the
      passed basis vector. Does not perform any transformation before setting
      the new vector basis (see the Vector.snap function for this behavior)

  Vector.snap(basis, vector) --> vector(table)
      Transforms vector from world space or another basis to the passed basis
      vector and returns the new relative vector.

          Example: Let a = World Vector < 5 10 15 >
                       b = World Vector < -5 3 5 >
                   Vector.snap(b, a) --> c       = Local Vector < 10 7 10 >
                                         c.basis = b

  Vector.snap(basis) --> vector(table)
      Returns a new, zero-magnitude vector relative to the provided basis.

  Vector.clone(vector) --> vector(table)
      Returns a deep copy of the passed vector maintaining its basis if set.

================================================================================
  Factory Methods:

  Vector.create(...) --> vector(table)
      Creates a new vector table of any number of dimensions.

  Vector.uniform(dimensions, value) --> vector(table)
      Creates a new vector of the passed number of dimensions with each
      component set to the passed value.

  Vector.uniform(dimensions) --> vector(table)
      Creates a new vector of zero magnitude with the passed number of
      dimensions.

================================================================================
  MIT License

  Copyright (c) 2017 Joshua Taylor

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
================================================================================

]]


local Vector = {
  _NAME = "cosmiclatte.vector",
  _VERSION = "0.1.0",
  _AUTHOR = "Joshua Taylor <taylor.joshua88@gmail.com>",
  _UPSTREAM = "https://github.com/taylorjoshua88/cosmiclatte",
  _LICENSE = "mit",
  _DESCRIPTION = "Generic lua-based vectors of any dimension"
}

local max = math.max
local sqrt = math.sqrt

local VectorMT = {
  __index = function(vec, i) --> Component value : number
    if i == "x" or i == "r" then
      return vec[1] or nil
    end
    if i == "y" or i == "g" then
      return vec[2] or nil
    end
    if i == "z" or i == "b" then
      return vec[3] or nil
    end
    if i == "a" or i == "w" then
      return vec[4] or nil
    end

    return Vector[i]
  end,

  __add = function(a, b) --> a + b : #result = max(#a, #b)
    local result = {}

    for i = 1, max(#a, #b) do
      result[i] = (a[i] or 0) + (b[i] or 0)
    end

    return setmetatable(result, VectorMT)
  end,

  __sub = function(a, b) --> a - b : #result = max(#a, #b)
    local result = {}

    for i = 1, max(#a, #b) do
      result[i] = (a[i] or 0) - (b[i] or 0)
    end

    return setmetatable(result, VectorMT)
  end,

  __mul = function(a, b) --> a * b : #result = max(#a, #b)
    local result = {}

    if type(b) == "number" then
      for i=1, #a do
        result[i] = a[i] * b
      end
    else
      for i=1, max(#a, #b) do
        result[i] = (a[i] or 1) * (a[i] or 1)
      end
    end

    return setmetatable(result, VectorMT)
  end,

  __div = function(a, b) --> a / b : #result = #a
    local result = {}

    if type(b) == "number" then
      for i=1, #a do
        result[i] = a[i] / b
      end
    else
      for i=1, #a do
        result[i] = a[i] / b[i]
      end
    end

    return setmetatable(result, VectorMT)
  end
}

function Vector.string(vec) --> String representation of vec : string
  local result

  if vec.basis then
    result = "Local Vector <"
  else
    result = "World Vector <"
  end

  for i = 1, #vec do
    result = string.format("%s %g", result, vec[i])
  end

  return result .. " >"
end

function Vector.set_relative(vector, newVector, basis) --| Sets vector to newVector absolutely in local coordinates to basis
  if not basis then
    assert(vector.basis, "Attempt to set a world vector relative with no basis")
    basis = vector.basis
  end

  vector = Vector.clone(newVector) or Vector.uniform(#vector)
  vector.basis = basis
end

function Vector.set_world(vector, newVector) --| Sets vector to newVector absolutely in world coordinates
  if newVector then
    vector = Vector.clone(newVector)
  end

  vector.basis = nil
end

function Vector.dot(a, b) --> a (dot) b : number
  assert(#a == #b, "Attempt to take dot product of unequal dimensions")

  local result = 0

  for i = 1, #a do
    result = result + a[i] * b[i]
  end

  return result
end

function Vector.cross(a, b) --> a (cross) b : #result = 3
  assert(#a == 3 and #b == 3, "Attempt to take cross product of vectors not of three dimensions")

  return setmetatable({
      a[2]*b[3] - a[3]*b[2],
      a[3]*b[1] - a[1]*b[3],
      a[1]*b[2] - a[2]*b[1]}, VectorMT)
end

function Vector.length_squared(vec) --> Squared length of vec : number
  local result = 0

  for i = 1, #vec do
    result = result + vec[i]^2
  end

  return result
end

function Vector.length(vec) --> Length of vec : number
  return sqrt(Vector.length_squared(vec))
end

function Vector.normalize(vec) --> Normalized representation of vec : #vec
  local length = Vector.length(vec)

  -- Prevent division by zero
  if length == 0 then
    return Vector.uniform(#vec)
  end

  local result = {}

  for i = 1, #vec do
    result[i] = vec[i] / length
  end

  return setmetatable(result, VectorMT)
end

function Vector.world(relativeVector) --> Vector transformed to world coordinates : #relativeVector
  if relativeVector.basis then
    assert(relativeVector.basis ~= relativeVector, "Vector's basis set to itself")
    return relativeVector + Vector.world(relativeVector.basis)
  end

  return Vector.clone(relativeVector)
end

function Vector.relative(basis, worldVector) --> Vector transformed to local coordinates : #worldVector
  local result = Vector.clone(worldVector)
  result.basis = basis
  return result
end

function Vector.snap(basis, vector) --> Vector snapped to a new basis maintaining its offset : max(#vector, #basis)
  local result = Vector.world(vector or Vector.uniform(#basis)) - Vector.world(basis)
  result.basis = basis
  return result
end

function Vector.clone(vector) --> Vector with the same values as the passed vector : #vector
  local result = {}

  for i = 1, #vector do
    result[i] = vector[i]
  end

  result.basis = vector.basis

  return setmetatable(result, VectorMT)
end

function Vector.create(...) --> New vector : #result = #(...)
--  assert(#(table.pack(...)), "Attempt to create dimensionless vector")

  return setmetatable({...}, VectorMT)
end

function Vector.uniform(dimensions, value) --> New vector with all components = value : #result = dimensions
--  assert(type(dimensions) == "number", "Attempt to create dimensionless uniform vector")

  local result = {}
  for i = 1, dimensions or 0 do result[i] = value or 0 end

  return setmetatable(result, VectorMT)
end

return setmetatable(Vector, { __call = function(_, ...) return Vector.create(...) end })
