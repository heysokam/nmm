# val.addr :: &val
# p[]      :: *p
# pointer arithmetic is  ptr UncheckedArray[T]
# instead of ptr + int

var a = 10
echo a.addr[] # !eval var a = 10; echo a.addr[]
var b = cast[ptr UncheckedArray[int]](create(int, 10))
for it in b.toOpenArray(0, 9):
  echo it


# pointer types are ptr T instead of *
# pointers to arrays are ptr UncheckedArray[T] instead of T**
# void pointers are pointer instead of void*

# Traced references are declared with the ref keyword
# untraced references are declared with the ptr keyword
# In general, a ptr T is implicitly convertible to the pointer type.

# Anything that uses pointers or cast is generally unsafe
# Search for all system procs that have ptr in arguments or return types
#   cast           :
#   ptr            :
#   pointer        :
#   addr           :
#   unsafeaddr     :
#   alloc          :
#   dealloc        :
#   create         :
#   resize         :
#   allocShared    :
#   deallocShared  :
#   createShared   :
#   freeShared     :

# If you want to get comfortable with pointers in Nim, make primitive types in it using unsafe methods
# Strings, sequences, linked lists

