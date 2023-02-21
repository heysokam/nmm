type RBColor = enum Empty, Red, Blk
type RBTree *[T]= ref object
  color  *:RBColor
  left   *:RBTree[T]
  right  *:RBTree[T]
  value  *:T

#.............................
proc newTree *[T]() :RBTree[T]=
  ## Returns a new empty RBTree
  new result; result = RBTree[T](color: Empty, left: nil, right: nil)
proc newTree *[T](value :T) :RBTree[T]=
  ## Returns a new RBTree that containes the given value
  new result; result = RBTree[T](color: Red, left: nil, right: nil, value: value)
#.............................
proc R [T](l :RBTree[T]; v :T; r :RBTree[T]) :RBTree[T]=  RBTree[T](color: Red, left: l, value: v, right: r)
  ## Returns a new Red RBTree with l, v, r
proc B [T](l :RBTree[T]; v :T; r :RBTree[T]) :RBTree[T]=  RBTree[T](color: Blk, left: l, value: v, right: r)
  ## Returns a new Black RBTree with l, v, r
proc E [T]() :RBTree[T]=  RBTree[T]()
  ## Returns a new Empty RBTree
#.............................


#.............................
proc member *[T](x :T, tree: RBTree[T]) :bool=
  ## Checks if the value is contained in the given RBTree
  if tree == nil: return false
  var cur = tree
  while cur != nil:
    if   x == cur.value:  return true
    elif x < cur.value:   cur = cur.left
    elif x > cur.value:   cur = cur.right
  return false

# #.............................
# proc makeBlack *[T](tree :RBTree[T]) :RBTree[T]=
#   ## Makes the given RBTree Black, unless its nil
#   new result
#   result = tree
#   if result != nil:  result.color = Blk

proc ins [T](tree :RBTree[T]; x :T) :RBTree[T]=
  new result
  result = tree
  if   result == nil:     result = R[T](E[T](), x, E[T]()); return
  if   x < result.value:  result.left  = result.left.ins(x)
  elif x > result.value:  result.right = result.right.ins(x)

proc insert *[T](tree :RBTree[T]; x :T) :RBTree[T]=
  ## Inserts the given value in the given tree
  new result
  result = tree.ins(x)
  result.color = Blk



var tree :RBTree[int]= newTree(1)
let val1 :int= 1
let val2 :int= 2
import print
print tree
echo val1.member(tree)
echo val2.member(tree)
tree = tree.insert(val2)
echo val2.member(tree)
print tree
for it in 0..5:
  tree = tree.insert(it.int)
print tree


