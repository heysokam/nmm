#.............................
import ../cfg
import ../types
import ../tools

#.............................
# Config
const DefArenaSize *:u8=  255

#.............................
# types/arena.nim
type ArenaV {.inheritable.}= object
  data *:u8p  ## Pointer to the byte data
  size *:u64  ## Max size of the arena
  prev *:u64  ## Previous offset
  curr *:u64  ## Current  offset
type Arena    * = ptr ArenaV
type ArenaTmp * = ptr object of Arena
#.............................
converter toBool *(a :Arena) :bool=  not a.isNil
#.............................
proc  offs   *(a :Arena)             :u64=       a.curr
proc `offs=` *(a :var Arena; v :u64) :void=      a.curr = v
proc  at     *(a :Arena; pos :u64)   :P=         a.data.at(pos)
proc  tmp    *(a :Arena)             :ArenaTmp=  cast[ArenaTmp](a)
#.............................
proc newArena *(size :u64= DefArenaSize) :Arena=
  ## Creates a new Arena Allocator of the default size
  result      = create ArenaV
  result.size = size
  result.data = u8.create(result.size)
#.............................
proc newArenaTmp *(arena :Arena) :ArenaTmp=
  result      = arena.tmp
  result.prev = arena.prev
  result.curr = arena.curr

#.............................
# State
var defArena *:Arena

#.............................
proc term *(arena :Arena) :void=
  ## Terminates the arena object itself
  arena.data.dealloc
  arena.dealloc
#.............................
proc init *(arena :var Arena; buf :P; bsize :u64) :void=
  ## Initalize the given arena with the target buffer and size
  arena.data = buf
  arena.size = bsize
  arena.curr = 0
  arena.prev = 0
#.............................
proc free *[T](val :T) :void=  discard
proc free *[T](arena :Arena; val :T) :void=  discard
  ## There is no point in freeing a value in an Arena Allocator
proc free *(arena :Arena) :void=
  ## Clears the whole Arena
  arena.curr = 0
  arena.prev = 0
proc free *(arena :ArenaTmp) :void=
  ## Clears the whole Arena
  arena.curr = 0
  arena.prev = 0



#.............................
proc alloc *(arena :var Arena; size :u64) :P=
  ## Allocate the given size in the arena
  if not arena: fail("Tried to allocate with an uninitialized Arena Allocator")
  # Check to see if the backing memory has space left
  if arena.offs+size <= arena.size:
    result = arena.data.at(arena.offs)
    arena.curr += size
  # Return nil if the Arena is OOM
  else: result = nil; err("Arena Allocator is out of room")
#.............................
proc aalloc *(size :u64) :P=
  ## Allocate the given size in the arena, using the default arena pointer
  if defArena == nil: defArena = newArena()
  defArena.alloc(size)


#.............................
proc alloca *(arena :Arena; size :u64; align :u64= DefAlign) :P=
  ## Allocate the given size, aligned to the given power of 2
  ## Uses the default arena pointer
  ## Will use 2*sizeof(pointer) as default when omitted
  # Align current offset forward to the specified alignment
  var curr :P= arena.start + arena.offs
  var offs :P= curr.alignForw(align)
  offs -= arena.start  # Change to relative offset
  # Check to see if the backing memory has space left
  if offs+size <= arena.size:
    result = arena.at(offs)
    arena.prev = offs
    arena.curr = offs+size
  # Return nil if the Arena is OOM
  else: result = nil; err("Arena Allocator is out of room")
#.............................
proc aalloca *(size :u64; align :u64= DefAlign) :P=
  ## Allocate the given size, aligned to the given power of 2
  ## Uses the default arena pointer
  ## Will use 2*sizeof(pointer) as default when omitted
  if defArena == nil: defArena = newArena()
  defArena.alloca(size)


#.............................
proc resize *(arena :Arena; oldData :P; oldSize, newSize :u64; align :u64= DefAlign) :P=
  var oldMem :u8p= oldData
  assert align.isPow2
  if not oldMem.isNil or oldSize == 0: 
    return arena.alloca(newSize, align)
  elif arena.data <= oldMem and oldMem < arena.data+arena.size:
    if arena.data+arena.prev == oldMem:
      arena.curr = arena.offs + newSize
      oldMem.zeroMem(newSize-oldSize)  # Zero the new memory by default
      return oldMem
    else:
      result = arena.alloca(newSize, align)
      let cpSize :u64= if oldSize < newSize: oldSize else: newSize
      result.moveMem(oldMem, cpSize)  # Copy across old memory to the new memory
      return
  else:
    false.assert("Memory is out of bounds of the buffer in this Arena")
    result = nil
#.............................
proc resize *(oldData :P; oldSize, newSize :u64; align :u64= DefAlign) :P=
  result = defArena.resize(oldData, oldSize, newSize, align)

