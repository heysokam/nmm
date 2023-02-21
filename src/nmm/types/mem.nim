import ./base

#.............................
# MMem Aliases
type P   * = pointer
type u8p * = ptr u8
type uA  *[T]= UncheckedArray[T]
type uAp *[T]= ptr uA[T]
#.............................
converter toBool *(p :P) :bool=  not p.isNil
converter toU64  *(p :P) :u64=   cast[u64](p)
converter toU8p  *(p :P) :u8p=   cast[u8p](p)
#.............................
# MMem type helpers
proc at *[T](p :ptr T; pos :u64) :P=  cast[uAp[T]](p)[pos].addr
proc toP *[T](n :T)       :P=  cast[P](n)
proc start *[T](p :ptr T) :P=  p.at(0)
proc `and` *(p1, p2 :P)   :P=  cast[P](cast[uAp[u64]](p1) and cast[uAp[u64]](p2))
proc `+` *(p1, p2 :P)     :P=  cast[P](cast[uAp[u64]](p1)  +  cast[uAp[u64]](p2))
proc `+` *[T](p :P; n :T) :P=  cast[P](cast[uAp[u64]](p)   +  n)
proc `-` *(p1, p2 :P)     :P=  cast[P](cast[uAp[u64]](p1)  -  cast[uAp[u64]](p2))
proc `-` *[T](p :P; n :T) :P=  cast[P](cast[uAp[u64]](p)   -  n)
proc `-=`*[T](p :var P; n :T) :void=  p = cast[P](cast[uAp[u64]](p) - n)
proc `+=`*[T](p :var P; n :T) :void=  p = cast[P](cast[uAp[u64]](p) + n)
proc `<=`*[T](p :P; n :T) :bool=  cast[uAp[u64]](p) <= n
proc `[]`*(p :u8p; id :Natural) :P=  cast[P](p[id])
