# import std/macros
# import fusion/matching
# {.experimental: "caseStmtMacros".}

type
  RBColor = enum Empty, Red, Black
  RBTree[T] = ref object
    color       :RBColor
    left, right :RBTree[T]
    value       :T

# proc `[]`[T](r :RBTree[T], idx :static[FieldIndex]) :auto=
#   ## enables tuple syntax for unpacking and matching
#   when idx == 0: r.color
#   elif idx == 1: r.left
#   elif idx == 2: r.value
#   elif idx == 3: r.right

template B [T](l :untyped; v :T, r) :RBTree[T]= 
  RBTree[T](color: Black, left: l, value: v, right: r)

template R [T](l :untyped; v :T, r) :RBTree[T]= 
  RBTree[T](color: Red, left: l, value: v, right: r)

template balImpl [T](t :typed): untyped =
  expandMacros:
    case t
    of (color: Red | Empty): discard
    of (Black, (Red, (Red, @a, @x, @b), @y, @c), @z, @d) |
       (Black, (Red, @a, @x, (Red, @b, @y, @c)), @z, @d) |
       (Black, @a, @x, (Red, (Red, @b, @y, @c), @z, @d)) |
       (Black, @a, @x, (Red, @b, @y, (Red, @c, @z, @d))):
       t = R(B(a, x, b), y, B(c, z, d))

proc balance*[T](t :var RBTree[T]) :void=  balImpl[T](t)

template insImpl[T](t, x: typed) :untyped=
  template E: RBTree[T] = RBTree[T]()
  case t
  of (color: Empty): t = R(E, x, E)
  of (value: > x):   t.left.ins(x); t.balance()
  of (value: < x):   t.right.ins(x); t.balance()

proc insert*[T](tt :var RBTree[T], xx :T) :void=
  proc ins(t :var RBTree[T], x :T) :void=  insImpl[T](t, x)
  tt.ins(xx)
  tt.color = Black

import print
when isMainModule:
  var root = RBTree[int]()
  for it in 0..15:
    root.insert(it.int)
  root.balance()
  # print root
