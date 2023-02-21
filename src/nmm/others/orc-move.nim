type myseq*[T] = object
  len  :int
  cap  :int
  data :ptr UncheckedArray[T]

proc `=destroy2`*[T](x :var myseq[T]) =
  if x.data != nil:
    for idx in 0..<x.len:
      `=destroy`(x.data[idx])
    dealloc(x.data)

proc `=trace2`[T](x :var myseq[T]; env :pointer) =
  # =trace allows the cycle collector  --mm:orc
  # to understand how to trace the object graph
  if x.data != nil:
    for idx in 0..<x.len:
      `=trace2`(x.data[idx], env)

proc `=copy2`*[T](a :var myseq[T]; b :myseq[T]) =
  # do nothing for self assignments:
  if a.data == b.data: return
  # erase a
  `=destroy2`(a)
  wasMoved(a)
  # copy b to a
  a.len = b.len
  a.cap = b.cap
  if b.data != nil:
    a.data = cast[typeof(a.data)](alloc(a.cap * sizeof(T)))
    for idx in 0..<a.len:
      a.data[idx] = b.data[idx]

proc `=sink2`*[T](a :var myseq[T]; b :myseq[T]) =
  # move assignment. optional.
  # Compiler is using =destroy and copyMem when not provided
  `=destroy2`(a)
  wasMoved(a)
  a.len  = b.len
  a.cap  = b.cap
  a.data = b.data

proc add*[T](x :var myseq[T]; y :sink T) =
  if x.len >= x.cap:
    # Grow the cap
    x.cap  = max(x.len+1, x.cap*2)
    # grow the memory, and cast it into data with the new size
    x.data = cast[typeof(x.data)](realloc(x.data, x.cap*sizeof(T)))
  x.data[x.len] = y  # Copy y into x
  inc x.len # Increment length by 1  ??
