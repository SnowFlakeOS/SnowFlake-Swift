#define lsize sizeof(word)
#define lmask (lsize - 1)

typedef unsigned int size_t;
typedef long word;

void *memcpy(void *dest, const void *src, size_t count);
void *memmove(void *s1, const void *s2, size_t n);
void bcopy(const void *s1, void *s2, size_t n);

void *memcpy(void *dest, const void *src, size_t count)
{

	char *d = (char *)dest;
	const char *s = (const char *)src;
	int len;
	if(count == 0 || dest == src)
		return dest;
	if(((long)d | (long)s) & lmask) {
		// src and/or dest do not align on word boundary
		if((((long)d ^ (long)s) & lmask) || (count < lsize))
			len = count; // copy the rest of the buffer with the byte mover
		else
			len = lsize - ((long)d & lmask); // move the ptrs up to a word boundary
		count -= len;
		for(; len > 0; len--)
			*d++ = *s++;
	}
	for(len = count / lsize; len > 0; len--) {
		*(word *)d = *(word *)s;
		d += lsize;
		s += lsize;
	}
	for(len = count & lmask; len > 0; len--)
		*d++ = *s++;
	return dest;
}

void *memmove(void *s1, const void *s2, size_t n)
{
	return memcpy(s1, s2, n);
}

void bcopy(const void *s1, void *s2, size_t n)
{
	memcpy(s2, s1, n);
}
