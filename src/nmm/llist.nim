
type Node[T] = ref object
  next  *:Node[T]
  data  *:T

type LList[T] = object
  head *:Node[T]
  tail *:Node[T]

proc newNode[T](data: T): Node[T] =
  Node[T](data: data)

proc append[T](list: var LList[T]; node: Node[T]) =
  if list.head.isNil:
    list.head = node
    list.tail = node
  else:
    list.tail.next = node
    list.tail = node

proc append[T](list: var LList[T]; data: T) =
  list.append newNode(data)

proc prepend[T](list: var LList[T]; node: Node[T]) =
  if list.head.isNil:
    list.head = node
    list.tail = node
  else:
    node.next = list.head
    list.head = node

proc prepend[T](list: var LList[T]; data: T) =
  list.prepend newNode(data)

proc `$`[T](list: LList[T]): string =
  var s: seq[T]
  var n = list.head
  while not n.isNil:
    s.add n.data
    n = n.next
  result = s.join(" → ")

var list: LList[int]

for i in 1..5: list.append(i)
for i in 6..10: list.prepend(i)
echo "List: ", $list
