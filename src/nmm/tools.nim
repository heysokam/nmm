import ./types

#.............................
# Debug
const LineSep    = "............................"
const NewLine    = "\n"
const BlockSep * = NewLine & LineSep
#.............................
template reprb *[T](n :T) :str= cast[ByteAddress](n.addr).repr
template repra *[T](n :T) :str= n.addr.repr & " " & n.reprb
#.............................
# Error management
type MMemException * = enum AllocDefect, AllocError
#.............................
proc err  *(exc :MMemException; msg :str) :void=
  case exc
  of   AllocDefect: echo "AllocDefect : "
  of   AllocError:  echo "AllocError : "
#.............................
proc err  *(msg :str) :void=  echo "ERR : ",msg
proc fail *(msg :str) :void=  echo "FAIL : ",msg; quit()


#.............................
# Memory Management Tools
proc isPow2 *(n :u64) :bool=  (n and (n-1)) == 0
#.............................
proc alignForw *(data :P; align :u64) :P=
  assert align.isPow2
  result     = data
  var aP   :P= align.toP
  var modP :P= result and (aP-1)  # Same as (p%a), but faster because a is pow2
  if modP: # If p is not aligned, push the address to the next aligned position
    result = result + aP - modP
#.............................
proc alignForw *(data, align :u64) :u64=
  assert align.isPow2
  result = data
  var aU :u64= align
  var modU :u64= result and (aU-1)
  if modU != 0:
    result = result + aU - modU

