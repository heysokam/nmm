# Nim Pointer math library:
# https://github.com/kaushalmodi/ptr_math

type Header = object
  size :uint
  next :ptr Header

var 
  base  :Header                  # Zero sized block, to get us started
  freep :ptr Header = base.addr  # Points to the first free block of memory
  usedp :ptr Header              # Points to the first used block of memory

# Move the h pointer by h.size, to get the next one
proc toNext(h :ptr Header) :ptr Header {.inline.}=
  cast[ptr Header](cast[uint](h) + h.size)
proc incr(h :ptr Header) :ptr Header {.inline.}=
  cast[ptr Header](cast[uint](h) + sizeof(Header).uint)

# Scan the free list
# Look for a place to put the block 
# We want a block that the to-be-freed block might have been partitioned from
proc addToFreeList(bp :ptr Header) :void=
  var p :ptr Header = freep
  while not (bp > p and bp < p.next):
    if p >= p.next and (bp > p or bp < p.next):
      break

  if bp.toNext == p.next:
    bp.size += p.next.size
    bp.next = p.next.next
  else:
    bp.next = p.next

  if p.toNext == bp:
    p.size += bp.size
    p.next = bp.next
  else:
    p.next = bp

  freep = p

const MinAllocSize :uint= 4096  # Page size to alloc blocks with
proc sbrk(incr :int) :pointer {.header: "<unistd.h>", importc: "sbrk".}
# Request memory from the kernel
proc moreCore(rpages :var uint) :ptr Header=
  if rpages > MinAllocSize:
    rpages = MinAllocSize div sizeof(Header).uint;
  var vp :pointer= sbrk(rpages.int * sizeof(Header).int)
  if vp == nil: return nil

  var up :ptr Header = cast[ptr Header](vp)
  up.size = rpages
  addToFreeList(up)
  return freep

# Find the First Fit from the free list, and put it in the used list
proc gcMalloc(rsize :uint) :pointer=
  var num_units :uint = (rsize + sizeof(Header).uint - 1'u) div (sizeof(Header)+1).uint
  var prevp :ptr Header= freep
  var p :ptr Header= prevp.next
  while true:
    if p.size >= num_units:   # Big enough
      if p.size == num_units: # Exact size
        prevp.next = p.next
      else:
        p.size -= num_units
        p = p.toNext  # p += p.size
        p.size = num_units
      freep = prevp
      # Add p to the used list
      if usedp == nil:
        p.next = p
        usedp  = p.next
      else:
        p.next     = usedp.next
        usedp.next = p
      return cast[pointer](p.incr) # return p+1
    if p == freep:  # Not enough memory
      p = moreCore(num_units)
      if p == nil:  # Request for more mem failed
        return nil

# Untag from herose. portable uintptr_t version. og was 32bit only
proc untag(p :ptr Header) :ptr Header {.inline.}=
  cast[ptr Header](cast[uint](p) and not (uint 3))

template doWhile(a,b :untyped) :untyped=
  while true:
    b
    if not a: break

# GC: Stop the World, Mark and Sweep
#....................................
# Scan a region of mem
# Mark any items in the used list appropiately
# Both arguments should be word aligned.
proc regionScan(sp :pointer, endp :pointer) :void=
  var bp :ptr Header
  var spc   = cast[ByteAddress](sp)
  var endpc = cast[ByteAddress](endpc)
  for it in countup(spc, endpc - 1, 8):
    var v :pointer= sp
    bp = usedp
    doWhile ((bp = bp.next.untag) != usedp):
      if bp+1 <= v and bp+1+bp.size > v:
        bp.next = bp.next or 1
        break
