# See LICENSE for license details.

#*****************************************************************************
# recoding.S
#-----------------------------------------------------------------------------
#
# Test corner cases of John Hauser's microarchitectural recoding scheme.
# There are twice as many recoded values as IEEE-754 values; some of these
# extras are redundant (e.g. Inf) and others are illegal (subnormals with
# too many bits set).
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64UF
RVTEST_CODE_BEGIN

  # Make sure infinities with different mantissas compare as equal.
  flw f0, minf, a0
  flw f1, three, a0
  fmul.s f1, f1, f0
  TEST_CASE( 2, a0, 1, feq.s a0, f0, f1)
  TEST_CASE( 3, a0, 1, fle.s a0, f0, f1)
  TEST_CASE( 4, a0, 0, flt.s a0, f0, f1)

  # When converting small doubles to single-precision subnormals,
  # ensure that the extra precision is discarded.
  flw f0, big, a0
  fld f1, tiny, a0
  fcvt.s.d f1, f1
  fmul.s f0, f0, f1
  fmv.x.s a0, f0
  lw a1, small
  TEST_CASE(10, a0, 0, sub a0, a0, a1)

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

minf: .float -Inf
three: .float 3.0
big: .float 1221
small: .float 2.9133121e-37
tiny: .double 2.3860049081905093e-40

RVTEST_DATA_END