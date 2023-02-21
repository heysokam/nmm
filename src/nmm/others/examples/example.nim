type TPerson* = object
  name :string
  age  :Natural
type Person* = ptr TPerson # Aliased used for cleanly refering to


proc newPerson(name :string, age :Natural): Person =
  result = create TPerson
  result.name = name
  result.age = age

proc free(p :Person) =
  if p != nil:
    dealloc p.name.unsafeAddr # Due to string being a ref need to free it
    dealloc p

proc `$`(p: Person): string =
  # Used only for debugging, leaking operation with --gc:none
  if p.isNil: "nil"
  else:       $p[]

var person: Person
echo person
person = newPerson("John", 35)
echo person
person.free
echo person
