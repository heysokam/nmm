import ../types
import ../tools

#.................................................
# Fixed-sized Pool Allocator
#.............................
# A pool allocator splits the supplied backing buffer into chunks of equal size
# and keeps track of which of the chunks are free.
# When an allocation is wanted, a free chunk is given.
# When a chunk is freed, it adds that chunk to the list of free chunks.
#
# Pool allocators are extremely useful when you need to allocate chunks of memory of the same size
# which are created and destroy dynamically, especially in a random order.
# Pools also have the benefit that arenas and stacks have:
# they provide very little fragmentation, and allocate/free in constant time O(1).
#
# Pool allocators are usually used to allocate groups of “things” at once which share the same lifetime.
# Example | a game that:
# - Creates and destroys entities in batches
# - Each entity within a batch share the same lifetime.
#
#.............................
# init      initialize the pool with a pre-allocated memory buffer
# alloc     removes the top element from the free list
# free      adds the freed chunk as the top of the free list
# free_all  adds every chunk in the pool onto the free list
#.................................................

#.............................
type 
  NodeV *{.inheritable.}= object
    fwd  *:Node  ## Next free node
  Node * = ptr NodeV
#.............................
type PoolV * = object
  data   *:u8p   ## Pointer to the byte data
  size   *:u64   ## Max size of the pool
  bsize  *:u64   ## Size of each block
  top    *:Node  ## Pointer to the top item in the free list
type Pool  * = ptr PoolV

#.............................
proc free *(p :Pool; data :P) :void=
  ## Adds the block containing the data into the free list
  if data.isNil: return  # Ignore null pointers
  var start :P= p.data
  var endp  :P= p.data[p.size]
  if not (start <= data and data < endp):
    false.assert("Memory is out of bounds of the buffer in this Pool")
    return
  # Add node to the free list
  var node :Node= cast[Node](data)
  node.fwd = p.top
  p.top    = node
#.............................
proc freeAll *(p :Pool) :void=
  ## Adds all blocks into the free list
  let bcount = p.size div p.bsize
  for blockId in 0..<bcount:
    var node :Node= cast[Node](p.data[blockId*p.bsize])
    # Add node to the free list
    node.fwd = p.top
    p.top    = node
#.............................
proc init *(p :Pool; buf :P; bufLen, bsize, balign :u64) :void=
  # Align the backing buffer to the specified block alignment
  var start1 :P= buf
  var start  :P= start1.alignForw(balign)
  var bufLen :u64= bufLen - start-start1
  # Align block size up to the required block alignment
  var bsize  :u64= bsize.alignForw(balign)
  # Assert that the parameters passed are valid
  assert bsize.i32 >= sizeof(NodeV), "Chunk size is too small"
  assert bufLen >= bsize, "Backing buffer length is smaller than the block size"
  # Store the adjusted parameters
  p.data  = buf
  p.size  = bufLen
  p.bsize = bsize
  p.top   = nil   # Top item of the free list
  p.freeAll()

#.............................
proc alloc *(p :Pool) :P=
  result = p.top.toP
  if result.isNil:
    assert false, "Pool allocator has no memory"
    return nil
  # Remove node from the free list
  p.top = p.top.fwd
  result.zeroMem(p.bsize)  # zero memory by default



























