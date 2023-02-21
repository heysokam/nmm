import ../types

#.............................
# Stack-like allocator (loose/small)
# The Stack acts like a data sctructure following the last-in, first-out (LIFO) principle
# The name is not related to the memory stack or the stack frame
#
# With an arena, memory can only be freed all at once
# In a stack, the offset can move backwards when freeing
#.............................
# init      initialize the stack with a pre-allocated memory buffer
# alloc     increments the offset to indicate the current buffer offset whilst taking into account the allocation header
# free      frees the memory passed to it and decrements the offset to free that memory
# resize    first checks to see if the allocation being resized was the previously performed allocation and if so, the same pointer will be returned and the buffer offset is changed. Otherwise, stack_alloc will be called instead.
# free_all  is used to free all the memory within the allocator by setting the buffer offsets to zero.
#.............................


#.............................
# stack/cfg.nim
import ../cfg
const DefStackSize * = 256

#.............................
# types/stack.nim
type StackV {.inheritable.}= object
  data *:u8p  ## Pointer to the byte data
  size *:u64  ## Max size of the stack
  curr *:u64  ## Current  offset
  prev *:u64  ## Previous offset
type Stack  * = ptr StackV
type StackHV {.inheritable.}= object
  pad  *:u8   ## Amount of padding to apply. Max is half of this type's size (128 for u8)
  # prev *:u64  ## For enforcing LIFO for frees
type StackH * = ptr StackHV
#.............................
converter toBool *(s :Stack) :bool=  not s.isNil
converter toStackH *(p :P) :StackH=  cast[StackH](p)
#.............................
proc  offs   *(s :Stack)             :u64=   s.curr
proc `offs=` *(s :var Stack; v :u64) :void=  s.curr = v
proc  at     *(s :Stack; pos :u64)   :P=     s.data.at(pos)
#.............................
proc newStack *(size :u64= DefStackSize) :Stack=
  ## Creates a new Stack Allocator of the default size
  result      = create StackV
  result.size = size
  result.data = u8.create(result.size)

#.............................
# stack/core.nim
#.............................
proc init *(stack :var Stack; buf :P; size :u64) :void=
  ## Initializes the stack with a pre-allocated memory buffer
  stack.data = buf
  stack.size = size
  stack.offs = 0

#.............................
import ../tools
#.............................
proc calcPadding (p :P; align :u64; h :typedesc) :u64=
  assert align.isPow2
  let modulo  :u64= p and (align-1)
  if modulo != 0: result = align - modulo
  var space :u64= sizeof(h).u64
  if result < space:
    space -= result
    if (space and (align-1)) != 0:
      result += align * (1+(space div align))
    else:
      result += align * (space div align)
  result = result
#.............................
proc alloc *(stk :var Stack; size :u64; align :u64= DefAlign) :P=
  assert align.isPow2
  var a = align.min(128) # Largest alignment is 128, because padding is 8bits(1byte)
  var currAddr :P= stk.data + stk.offs
  let padding :u64= currAddr.calcPadding(a, StackH)
  if stk.offs + padding + size > stk.size: err("Arena Allocator is out of room"); return nil
  stk.offs = stk.offs + padding
  result   = currAddr + padding
  var header :StackH= create StackHV
  header     = result - sizeof(StackH)
  header.pad = padding.u8
  stk.offs   = stk.offs + size
  result.zeroMem(size)
#.............................
proc free *(stk :var Stack; p :P) :void=
  if p.isNil: return
  var start :P= stk.data
  var endp  :P= start + stk.size
  var currAddr :P= p
  if not (start <= currAddr and currAddr < endp):
    assert false, "Out of Bounds memory address passed to stack allocator free()"
    return
  if currAddr >= start+stk.offs: return  # Allow double frees
  var h        :StackH= currAddr-sizeof(StackH)
  var prevOffs :u64=    currAddr-h.pad-start
  stk.offs = prevOffs
#.............................
proc freeAll *(stk :var Stack) :void=  stk.offs = 0

#.............................
proc resize *(stk :var Stack, p :P; oldSize, newSize :u64; align :u64= DefAlign) :P=
  if   p.isNil:       return stk.alloc(newSize, align)
  elif newSize == 0:  stk.free(p); return nil
  var start :P= stk.data
  var endp  :P= start + stk.size
  var currAddr :P= p
  if not (start <= currAddr and currAddr < endp):
    assert false, "Out of Bounds memory address passed to stack allocator resize()"
    return
  if currAddr >= start + stk.offs: return nil  # Treat as a  double free
  if oldSize == newSize: return p
  result = stk.alloc(newSize, align)
  let minSize = if oldSize < newSize: oldSize else: newSize
  moveMem(result, p, minSize)

