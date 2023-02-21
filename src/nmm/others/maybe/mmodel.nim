const LineSep = "............................"
const NewLine = "\n"
const BlockSep = NewLine & LineSep

template reprb(n :int) :string= cast[ByteAddress](n.addr).repr
template repra(n :int) :string= n.addr.repr & " " & n.reprb

var num :int
var p = num.addr
p[] = 30
echo num.reprb
echo num.addr.repr
echo num

echo BlockSep #..................
var lst = @[0x30, 0x40, 0x50]
echo lst.repr
echo lst.len
echo lst[0].repra
echo lst[1].repra
echo lst[2].repra

echo BlockSep #..................
# type TGSeq = object
  # `len`, reserved: int

var a = @[10, 20, 30]
# var b = cast[ptr TGSeq](a)
# echo b.repra
