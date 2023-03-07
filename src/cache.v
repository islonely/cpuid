module cpuid

// CacheLevel is the available caches for the CPU. Level 1 instruction, Level 1 data, Level 2, and Level 3.
pub enum CacheLevel {
	@none
	l1
	l2
	l3
	l4
	count
	unknown = 0xff
}

// CacheType is the different types of cache available.
pub enum CacheType {
	@none = -1
	data = 1
	instruction = 2
	unified = 3
	tlb = 4
	dtlb = 5
	stlb = 6
	prefetch = 7
	count
	unknown = 0xff
}

// Cache represents a CPU cache.
struct Cache {
pub:
	level      CacheLevel
	@type      CacheType
	size       int // size (of pages for TLB) in kilobytes
	ways       int // associativity: 0 = undefined/unknown, 255 = fully associative
	line_size  int // size in bytes
	entries    int // number of entries for TLB
	partitions int
}
