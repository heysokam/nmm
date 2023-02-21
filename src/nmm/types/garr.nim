import ./base

# !  !
# TODO: They should take an allocator as a parameter
# !  !
#
type GrowableArray *[T]= ptr object
  len, cap :int
  data     :UncheckedArray[T]

type GrowableArray2 *[T]= object
  len, cap :int
  data     :ptr UncheckedArray[T]

# New strings in Nim are 
type GrowableArray3 *[T]= object
  len   :int
  data  :ptr (int, UncheckedArray[T])

#.............................
type GArrayV *[T]= object
  arr   *:ptr T
  used  *:u64
  size  *:u64
type GArray *[T]= ptr GArrayV[T]

#.............................
proc isFull *[T](ga :GArray[T]) :bool=  ga.used*sizeof(T) == ga.size
  ## Checks whether the given Growable Array is full or not
  ## ga.used is the number of elements,
  ## so the ga is full when ga.used*sizeof(T) equals ga.size

#.............................
proc init *[T](ga :GArray[T]; size :u64) :void=
  ## Initializes the given Growable Array with the given size
  ga.arr  = T.create(size)
  ga.used = 0
  ga.size = size

#.............................
proc insert *[T](ga: GArray[T]; val :T) :void=
  if ga.isFull:
    ga.size.inc(sizeof(T))
    ga.arr.realloc(ga.size)
  ga.arr[ga.used.inc] = val

#.............................
proc free *[T](ga :GArray[T]) :void=
  ga.arr.dealloc
  ga.arr  = nil
  ga.used = 0
  ga.size = 0

