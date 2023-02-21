import ../types
import ../tools
#.............................

#.............................
# Needs both block size and padding, so its bigger than the stack alloc header
type ListH = object
  bsize  *:u64
  pad    *:u64

type 
  ListNodeV = object
    fwd    *:ListNode
    bsize  *:u64
  ListNode = ptr ListNodeV
  ## Linked list for the memory blocks

type Policy {.pure.} = enum First, Best

type List * = object
  data   *:u8p       ## Pointer to the byte data
  size   *:u64       ## Max size of the List
  used   *:u64       ## Amount of bytes currently used
  top    *:ListNode  ## Pointer to the top item in the free list
  pol    *:Policy    ## How data will be managed

#.............................


#.............................
proc freeAll *(fl :var List) :void=
  fl.used     = 0
  var first   :ListNode= fl.data
  first.bsize = fl.size
  first.fwd   = nil
  fl.top      = first
#.............................
proc init *(fl :var List; data :P; size :u64) :void=
  fl.data = data
  fl.size = size
  fl.freeAll

#.............................
# Alloc
# To allocate a block of memory within this allocator, we need to look for a block in the memory in which to fit our data. 
# This means iterating across our linked list of free memory blocks until a block has at least the size requested, 
# and then remove it from the linked list of free memory. 
# Finding the first block is called a first-fit placement policy 
# as it stops at the first block which fits the requested memory size. 
# Another placement policy is called the best-fit 
# which looks for a free block of memory which is the smallest available which fits the memory size. 
# The latter option reduces memory fragmentation within the allocator.
#.............................
proc first *(fl :var List; size, align :u64; pad :ptr u64; prev :ptr ListNode)
  ## Iterates the list and finds the first node with enough space


