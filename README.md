# cosmiclatte
Generic Lua-based vectors and math functions for use in games and real-time
simulation software.

## License
    MIT License
    Copyright (c) 2017 - 2018 Joshua Taylor
    
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

## Description
This module provides Lua (LuaGIT version planned) functions for vectors of
any number of dimensions. Returned tables can be used via the table returned
by this module or via OOP-style code.
  
## Getting started
Simply clone the cosmiclatte repository from GitHub and include the following
at the top of your Lua source files after copying the cosmiclatte folder into
your project's source directory:

    local Vector = require "cosmiclatte.vector"
  
## Architecture
Returned vectors are simply tables with a metatable for arithmetic operations.
Each component of vectors are indexed from 1 to remain consistent with the
Lua standard libraries. The __index metamethod will translate requests to "x",
"y", "z", "w" and "r", "g", "b", "a" to their respective indexes; therefore,
it is more efficient to refer to the coordinates by index rather than by
component name in loops.
  
The __index metamethod also maps to the Vector table, providing an OOP-like
interface to all vector tables. If the "basis" property is set on a vector to
another vector, then the vector will be interpreted as being relative to that
vector. Vectors can be converted back and forth between world and local
coordinates using Vector.world, Vector.relative, Vector.set_world,
Vector.set_relative, and Vector.snap.

### Unit Testing
The cosmiclatte repository contains a submodule to the utest repository on Github.
This library is used to perform all unit testing for cosmiclatte. To run the full
test suite, either run the "runFullTestSuite.sh" script within the root of this
repository in an sh-compatible shell, or run the "fullsuite.lua" script from the
"tests/" subdirectory of this repository in your Lua environment.

### Metamethods
    __index(vec, i) --> number
        Translates coordinate or color components to numeric indexes to retrieve
        those components' values.
    __eq(a, b) --> boolean
        Checks that a and b have the same number of components and that they all
        equal one another without regard to basis.
    __add(a, b) --> vector(table)
    __sub(a, b) --> vector(table)
    __mul(a, b) --> vector(table)
    __div(a, b) --> vector(table)
        Performs a component-wise arithmetic operation between two vectors or a
        scalar (__mul and __div). The resultant vector assumes the dimensions of
        the highest-dimension vector, except for __div which always uses a.

### Conversion Functions
    Vector.string(vec) --> string
        Returns a string representation of vec. The output will display whether
        the vector is in world or local coordinates along with the component
        values enclosed in '<' and '>' characters.
            Examples: "Local Vector < -0.680414 0.272166 0.680414 >"
                      "World Vector < 2 -5 17 >"
### Setter Functions
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

### Vector Math Functions
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

### Transformation Functions
    Vector.world(relativeVector) --> vector(table)
        Recursively transforms the passed vector based on its basis vector or
        simply return a copy of the passed vector if it was already in world
        coordinates.
    Vector.relative(worldVector, basis) --> vector(table)
        Returns a copy of the passed worldVector as a vector relative to the
        passed basis vector. Does not perform any transformation before setting
        the new vector basis (see the Vector.snap function for this behavior)
    Vector.snap(vector, basis) --> vector(table)
        Transforms vector from world space or another basis to the passed basis
        vector and returns the new relative vector.
            Example: Let a = World Vector < 5 10 15 >
                         b = World Vector < -5 3 5 >
                     Vector.snap(b, a) --> c       = Local Vector < 10 7 10 >
                                           c.basis = b
    Vector.snap(vector, basis) --> vector(table)
        Returns a new, zero-magnitude vector relative to the provided basis.

### Factory Methods
    Vector.create(...) --> vector(table)
        Creates a new vector table of any number of dimensions.
    Vector.uniform(dimensions, value) --> vector(table)
        Creates a new vector of the passed number of dimensions with each
        component set to the passed value.
    Vector.uniform(dimensions) --> vector(table)
        Creates a new vector of zero magnitude with the passed number of
        dimensions.
    Vector.clone(vector) --> vector(table)
        Returns a deep copy of the passed vector maintaining its basis if set.
