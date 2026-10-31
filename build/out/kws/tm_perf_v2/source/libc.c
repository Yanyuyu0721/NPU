#include <stddef.h>
#include <stdint.h>
/* GCC's may_alias type explicitly permits word accesses to byte/INT8 arrays.
 * Do not replace this with a plain uint32_t cast: strict aliasing is enabled.
 * RV32 requires aligned accesses, so differing alignments use the byte path. */
#if defined(__GNUC__)
typedef uint32_t edge_copy_word __attribute__((__may_alias__));
#endif
void *memcpy(void *d,const void *s,size_t n) {
 unsigned char *a=d;const unsigned char *b=s;
#if defined(__GNUC__)
 if((((uintptr_t)a^(uintptr_t)b)&3U)==0){
  while(n&&((uintptr_t)a&3U)){*a++=*b++;--n;}
  while(n>=4){*(edge_copy_word *)a=*(const edge_copy_word *)b;a+=4;b+=4;n-=4;}
 }
#endif
 while(n--)*a++=*b++;return d;
}
void *memset(void *d,int x,size_t n) { unsigned char *a=d;while(n--)*a++=(unsigned char)x;return d; }
int memcmp(const void *a,const void *b,size_t n) { const unsigned char *x=a,*y=b;while(n--){if(*x!=*y)return *x-*y;++x;++y;}return 0; }
