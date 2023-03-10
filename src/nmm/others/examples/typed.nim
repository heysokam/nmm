# Allocate thread local heap memory
var a = alloc(1000)
dealloc(a)

# Allocate memory block on shared heap
var b = allocShared(1000)
deallocShared(b)

# Allocate and Deallocate a single int, on the thread local heap
var p = create(int, sizeof(int)) # alloc memory
# Create zeroes the memory,  createU  does not
echo p[]             # 0
p[] = 123            # Assign a value
echo p[]             # 123
discard resize(p, 0) # Deallocate it
# p is now invalid. Let's set it to nil
p = nil              # set pointer to nil
echo isNil(p)        # true
