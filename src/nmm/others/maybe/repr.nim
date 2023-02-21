type Header = object
  size :uint
  next :ptr Header

proc HeaderNew(size :uint; next :ptr Header) :Header=
  result.size = size
  result.next = next

proc toNext(h :ptr Header) :ptr Header {.inline.}=
  cast[ptr Header](cast[uint](h) + h.size)

proc doThing()=
  var 
    thing1 :Header= HeaderNew(uint sizeof(Header), nil)
    thing2 :Header= HeaderNew(uint 2, nil)
    bp     :ptr Header = thing1.addr
    p      :ptr Header = thing2.addr
  bp.next = p
  echo repr(bp)
  echo repr(p)
  echo repr(bp.next)
  # if bp.toNext == p.next

doThing()
