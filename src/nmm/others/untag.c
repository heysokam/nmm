#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

typedef struct Header_s {
  unsigned int     size;
  struct Header_s* next;
} Header;

#define UNTAG_32b(p) (((unsigned int) (p)) & 0xfffffffc)
#define TAG_32b(p)   (((unsigned int) (p)) | 1)

#define UNTAG(p)       (((uintptr_t) (p)) & ~(uintptr_t)3)
#define GETTAG(p)      (((uintptr_t) (p)) &  (uintptr_t)3)
#define MERGETAG(p, v) (((uintptr_t) UNTAG(p)) | (v & 3))
#define TAG(p)         (((uintptr_t) (p)) |  (uintptr_t)1)

bool is_odd(int num){ return value & 1 ? true : false; )

int main(void) {
  Header* prev;
  Header* bp;
  printf("next:  %p\n", bp->next);
  printf("untag: %p\n", UNTAG(bp->next));
  printf("next:  %p\n", bp->next);
  printf("tag:   %p\n", TAG(bp->next));
  printf("next:  %p\n", bp->next);
}
