import ./types

#.............................
import ./alloc/arena as arena
#.............................
proc tstArena()=
  for it in 0..<(256/8).i8:
    echo aalloc(8).repr, " ", defArena.offs

  # One option is to give an array
  var bb1 :array[256, u8]
  var aa1 :Arena= newArena(256)
  aa1.init(bb1.addr, 256)
  echo aa1.at(0).repr
  # Another approach is to use std/system:
  var bb2 :P= create(P, 256)
  var aa2 :Arena= newArena(256)
  aa2.init(bb2.addr, 256)
  echo aa2.at(0).repr

#.............................
import ./alloc/stack as stack
#.............................
proc tstStack()= discard

import ./alloc/pool as pool


#.............................
when isMainModule: tstStack()
