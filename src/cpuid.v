module cpuid

import strings

// Vendor is a representation of a CPU vendor.
pub enum Vendor {
	unknown
	intel
	amd
	ibm
	via
	transmeta
	nsc
	hygon
	sis
	rdc
	ampere
	arm
	broadcom
	cavium
	dec
	fujitsu
	infineon
	motorola
	nvidia
	amcc
	qualcomm
	marvell
	// virutal machines
	kvm
	hyperv
	qemu
	vmware
	xenhvm
	bhyve
	// vendor count
	count
}

// FeatureID is the ID of a specific CPU feature.
pub enum FeatureID {
	unknown = -1
	adx // Intel ADX (Multi-Precision Add-Carry Instruction Extensions)
	aensi // Advanced Encryption Standard New Instructions
	amd3dnow // AMD 3DNOW
	amd3dnowext // AMD 3DNowExt
	amxbf16 // Tile computational operations on BFLOAT16 numbers
	amxfp16 // Tile computational operations on FP16 numbers
	amxint8 // Tile computational operations on 8-bit integers
	amxtile // Tile architecture
	avx // AVX functions
	avx2 // AVX2 functions
	avx512bf16 // AVX-512 BFLOAT16 Instructions
	avx512bitalg // AVX-512 Bit Algorithms
	avx512bw // AVX-512 Byte and Word Instructions
	avx512cd // AVX-512 Conflict Detection Instructions
	avx512dq // AVX-512 Doubleword and Quadword Instructions
	avx512er // AVX-512 Exponential and Reciprocal Instructions
	avx512f // AVX-512 Foundation
	avx512fp16 // AVX-512 FP16 Instructions
	avx512ifm // AVX-512 Integer Fused Multiply-Add Instructions
	avx512pf // AVX-512 Prefetch Instructions
	avx512vbmi // AVX-512 Vector Bit Manipulation Instructions
	avx512vbmi2 // AVX-512 Vector Bit Manipulation Instructions, Version 2
	avx512vl // AVX-512 Vector Length Extensions
	avx512vnni // AVX-512 Vector Neural Network Instructions
	avx512vp2intersect // AVX-512 Intersect for D/Q
	avx512vpopcntdq // AVX-512 Vector Population Count Doubleword and Quadword
	avxifma // AVX-IFMA instructions
	avxneconvert // AVX-NE-CONVERT instructions
	avxslow // Indicates the CPU performs 2 128 bit operations instead of one
	avxvnni // AVX (VEX encoded) VNNI neural network instructions
	avxvnniint8 // AVX-VNNI-INT8 instructions
	bhi_ctrl // Branch History Injection and Intra-mode Branch Target Injection / CVE-2022-0001, CVE-2022-0002 / INTEL-SA-00598
	bmi1 // Bit Manipulation Instruction Set 1
	bmi2 // Bit Manipulation Instruction Set 2
	cetibt // Intel CET Indirect Branch Tracking
	cetss // Intel CET Shadow Stack
	cldemote // Cache Line Demote
	clmul // Carry-less Multiplication
	clzero // CLZERO instruction supported
	cmov // i686 CMOV
	cmpccxadd // CMPCCXADD instructions
	cmpsb_scadbs_short // Fast short CMPSB and SCASB
	cmpxchg8 // CMPXCHG8 instruction
	cpboost // Core Performance Boost
	cppc // AMD: Collaborative Processor Performance Control
	cx16 // CMPXCHG16B Instruction
	efer_lmsle_uns // AMD: =Core::X86::Msr::EFER[LMSLE] is not supported, and MBZ
	enqcmd // Enqueue Command
	erms // Enhanced REP MOVSB/STOSB
	f16c // Half-precision floating-point conversion
	flush_l1d // Flush L1D cache
	fma3 // Intel FMA 3. Does not imply AVX.
	fma4 // Bulldozer FMA4 functions
	fp128 // AMD: When set, the internal FP/SIMD execution datapath is no more than 128-bits wide
	fp256 // AMD: When set, the internal FP/SIMD execution datapath is no more than 256-bits wide
	fsrm // Fast Short Rep Mov
	fxsr // FXSAVE, FXRESTOR instructions, CR4 bit 9
	fxsropt // FXSAVE/FXRSTOR optimizations
	gfni // Galois Field New Instructions. May require other features (AVX, AVX512VL,AVX512F) based on usage.
	hle // Hardware Lock Elision
	hreset // If set CPU supports history reset and the IA32_HRESET_ENABLE MSR
	htt // Hyperthreading (enabled)
	hwa // Hardware assert supported. Indicates support for MSRC001_10
	hybrid_cpu // This part has CPUs of more than one type.
	hypervisor // This bit has been reserved by Intel & AMD for use by hypervisors
	ia32_arch_cap // IA32_ARCH_CAPABILITIES MSR (Intel)
	ia32_core_cap // IA32_CORE_CAPABILITIES MSR
	ibpb // Indirect Branch Restricted Speculation (IBRS) and Indirect Branch Predictor Barrier (IBPB)
	ibrs // AMD: Indirect Branch Restricted Speculation
	ibrs_preferred // AMD: IBRS is preferred over software solution
	ibrs_provides_smp // AMD: IBRS provides Same Mode Protection
	ibs // Instruction Based Sampling (AMD)
	ibsbrntrgt // Instruction Based Sampling Feature (AMD)
	ibsfetchsam // Instruction Based Sampling Feature (AMD)
	ibsffv // Instruction Based Sampling Feature (AMD)
	ibsopcnt // Instruction Based Sampling Feature (AMD)
	ibsopcntext // Instruction Based Sampling Feature (AMD)
	ibsopsam // Instruction Based Sampling Feature (AMD)
	ibsrdwropcnt // Instruction Based Sampling Feature (AMD)
	ibsripinvalidchk // Instruction Based Sampling Feature (AMD)
	ibs_fetch_ctlx // AMD: IBS fetch control extended MSR supported
	ibs_opdata4 // AMD: IBS op data 4 MSR supported
	ibs_opfuse // AMD: Indicates support for IbsOpFuse
	ibs_preventhost // Disallowing IBS use by the host supported
	ibs_zen4 // AMD: Fetch and Op IBS support IBS extensions added with Zen4
	idpred_ctrl // IPRED_DIS
	int_wbinvd // WBINVD/WBNOINVD are interruptible.
	invlpgb // NVLPGB and TLBSYNC instruction supported
	lahf // LAHF/SAHF in long mode
	lam // If set, CPU supports Linear Address Masking
	lbrvirt // LBR virtualization
	lzcnt // LZCNT instruction
	mcaoverflow // MCA overflow recovery support.
	mcdt_no // Processor do not exhibit MXCSR Configuration Dependent Timing behavior and do not need to mitigate it.
	mcommit // MCOMMIT instruction supported
	md_clear // VERW clears CPU buffers
	mmx // standard MMX
	mmxext // SSE integer functions or AMD MMX ext
	movbe // MOVBE instruction (big-endian)
	movdir64b // Move 64 Bytes as Direct Store
	movdiri // Move Doubleword as Direct Store
	movsb_zl // Fast Zero-Length MOVSB
	movu // AMD: MOVU SSE instructions are more efficient and should be preferred to SSE	MOVL/MOVH. MOVUPS is more efficient than MOVLPS/MOVHPS. MOVUPD is more efficient than MOVLPD/MOVHPD
	mpx // Intel MPX (Memory Protection Extensions)
	msrirc // Instruction Retired Counter MSR available
	msrlist // Read/Write List of Model Specific Registers
	msr_pageflush // Page Flush MSR available
	nrips // Indicates support for NRIP save on VMEXIT
	nx // NX (No-Execute) bit
	osdxsave // XSAVE enabled by OS
	pconfig // PCONFIG for Intel Multi-Key Total Memory Encryption
	popcnt // POPCNT instruction
	ppin // AMD: Protected Processor Inventory Number support. Indicates that Protected Processor Inventory Number (PPIN) capability can be enabled
	prefetchi // PREFETCHIT0/1 instructions
	psfd // Predictive Store Forward Disable
	rdpru // RDPRU instruction supported
	rdrand // RDRAND instruction is available
	rdseed // RDSEED instruction is available
	rdtscp // RDTSCP Instruction
	rrsba_ctrl // Restricted RSB Alternate
	rtm // Restricted Transactional Memory
	rtm_always_abort // Indicates that the loaded microcode is forcing RTM abort.
	seialize // Serialize Instruction Execution
	sev // AMD Secure Encrypted Virtualization supported
	sev_64bit // AMD SEV guest execution only allowed from a 64-bit host
	sev_alternative // AMD SEV Alternate Injection supported
	sev_debugswap // Full debug state swap supported for SEV-ES guests
	sev_us // AMD SEV Encrypted State supported
	sev_restricted // AMD SEV Restricted Injection supported
	sev_snp // AMD SEV Secure Nested Paging supported
	sgx // Software Guard Extensions
	sgxlc // Software Guard Extensions Launch Control
	sha // Intel SHA Extensions
	sme // AMD Secure Memory Encryption supported
	sme_coherent // AMD Hardware cache coherency across encryption domains enforced
	spec_ctrl_ssbd // Speculative Store Bypass Disable
	srbds_ctrl // SRBDS mitigation MSR available
	sse // SSE functions
	sse2 // P4 SSE functions
	sse3 // Prescott SSE3 functions
	sse4 // Penryn SSE4.1 functions
	sse42 // Nehalem SSE4.2 functions
	sse4a // AMD Barcelona microarchitecture SSE4a instructions
	ssse3 // Conroe SSSE3 functions
	stibp // Single Thread Indirect Branch Predictors
	stibp_alwayson // AMD: Single Thread Indirect Branch Prediction Mode has Enhanced Performance and may be left Always On
	stosb_short // Fast short STOSB
	succor // Software uncorrectable error containment and recovery capability.
	svm // AMD Secure Virtual Machine
	svmda // Indicates support for the SVM decode assists.
	svmfbasid // SVM, Indicates that TLB flush events, including CR3 writes and CR4.PGE toggles, flush only the current ASID's TLB entries. Also indicates support for the extended VMCBTLB_Control
	svml // AMD SVM lock. Indicates support for SVM-Lock.
	svmnp // AMD SVM nested paging
	svmpf // SVM pause intercept filter. Indicates support for the pause intercept filter
	svmpft // SVM PAUSE filter threshold. Indicates support for the PAUSE filter cycle count threshold
	syscall // System-Call Extension (SCE): SYSCALL and SYSRET instructions.
	sysee // SYSENTER and SYSEXIT instructions
	tbm // AMD Trailing Bit Manipulation
	tlb_flush_nested // AMD: Flushing includes all the nested translations for guest translations
	tme // Intel Total Memory Encryption. The following MSRs are supported: IA32_TME_CAPABILITY, IA32_TME_ACTIVATE, IA32_TME_EXCLUDE_MASK, and IA32_TME_EXCLUDE_BASE.
	topext // TopologyExtensions: topology extensions support. Indicates support for CPUID Fn8000_001D_EAX_x[N:0]-CPUID Fn8000_001E_EDX.
	tscratemsr // MSR based TSC rate control. Indicates support for MSR TSC ratio MSRC000_0104
	tsxldtrk // Intel TSX Suspend Load Address Tracking
	vaes // Vector AES. AVX(512) versions requires additional checks.
	vmcbclean // VMCB clean bits. Indicates support for VMCB clean bits.
	vmpl // AMD VM Permission Levels supported
	vmsa_regprot // AMD VMSA Register Protection supported
	vmx // Virtual Machine Extensions
	vpclmulqdq // Carry-Less Multiplication Quadword. Requires AVX for 3 register versions.
	vte // AMD Virtual Transparent Encryption supported
	waitpkg // TPAUSE, UMONITOR, UMWAIT
	wbnoinvd // Write Back and Do Not Invalidate Cache
	wrmsrns // Non-Serializing Write to Model Specific Register
	x87 // FPU
	xgetbv1 // Supports XGETBV with ECX = 1
	xop // Bulldozer XOP functions
	xsave // XSAVE, XRESTOR, XSETBV, XGETBV
	xsavec // Supports XSAVEC and the compacted form of XRSTOR.
	xsaveopt // XSAVEOPT available
	xsaves // Supports XSAVES/XRSTORS and IA32_XSS
	// ARM features:
	aesarm // AES instructions
	armcpuid // Some CPU ID registers readable at user-level
	asimd // Advanced SIMD
	asimddp // SIMD Dot Product
	asimdhp // Advanced SIMD half-precision floating point
	asimdrdm // Rounding Double Multiply Accumulate/Subtract (SQRDMLAH/SQRDMLSH)
	atomics // Large System Extensions (LSE)
	crc32 // CRC32/CRC32C instructions
	dcpop // Data cache clean to Point of Persistence (DC CVAP)
	evtstrm // Generic timer
	fcma // Floatin point complex number addition and multiplication
	fp // Single-precision and double-precision floating point
	fphp // Half-precision floating point
	gpa // Generic Pointer Authentication
	jscvt // Javascript-style double->int convert (FJCVTZS)
	lrcpc // Weaker release consistency (LDAPR, etc)
	pmull // Polynomial Multiply instructions (PMULL/PMULL2)
	sha1 // SHA-1 instructions (SHA1C, etc)
	sha2 // SHA-2 instructions (SHA256H, etc)
	sha3 // SHA-3 instructions (EOR3, RAXI, XAR, BCAX)
	sha512 // SHA512 instructions
	sm3 // SM3 instructions
	sm4 // SM4 instructions
	sve // Scalable Vector Extension
	count
}

// CPUInfo contains information about the detected system CPU.
struct CPUInfo {
pub mut:
	brand_name       string // brand name reported by the cpu
	vendor           Vendor // vendor name
	features         []bool // features of the CPU
	physical_cores   int    // Number of physical processor cores in your CPU. Will be 0 if undetectable
	threads_per_core int = 1 // Number of threads per physical core. Will be 1 if undetectable.
	logical_cores    int    // Number of physical cores times threads that can run on each core through the use of hyperthreading. Will be 0 if undetectable.
	family           int    // CPU family number
	model            int    // CPU model number
	stepping         int    // CPU stepping info
	cache_line       int    // Cache line size in bytes. Will be 0 if undetectable.
	freqency         i64    // Clock speed, if known, 0 otherwise. Will attempt to contain base clock speed.
	boost_frequency  i64    // Max clock speed, if known, 0 otherwise.
	cache            struct {
	pub mut:
		l1i int = -1 // L1 Instruction Cache (per core or shared). Will be -1 if undetectable.
		l1d int = -1 // L1 Data Cache (per core or shared). Will be -1 if undetectable.
		l2  int = -1 // L2 Cache (per core or shared). Will be -1 if undetectable.
		l3  int = -1 // L3 Cache (per core or shared). Will be -1 if undetectable.
	}

	max_fn    u32
	max_ex_fn u32
}

// cpu will detect current CPU info and return it.
pub fn cpu() CPUInfo {
	mut c := CPUInfo{}
	c.brand_name, c.vendor = vendor()
	return c
}

// vendor returns the CPU vendor ID and Vendor
fn vendor() (string, Vendor) {
	mut vendor_bldr := strings.new_builder(12)
	regs := asm_cpuid(eax: 0)
	vendor_bldr.write_string(regs.stringify('b'))
	vendor_bldr.write_string(regs.stringify('d'))
	vendor_bldr.write_string(regs.stringify('c'))
	vendor_label := vendor_bldr.str()

	// Vendor set based off of this:
	// https://en.wikipedia.org/wiki/CPUID
	return match vendor_label {
		'AMDisbetter!', 'AuthenticAMD' { 'AMD', Vendor.amd }
		'CentaurHauls', 'VIA VIA VIA ' { 'VIA', Vendor.via }
		'CyrixInstead' { 'IBM', Vendor.ibm }
		'GenuineIntel' { 'Intel', Vendor.intel }
		'TransmetaCPU', 'GenuineTMx86' { 'Transmeta', Vendor.transmeta }
		'Geode by NSC' { 'National Semiconductor', Vendor.nsc }
		'NexGenDriven' { 'NexGen', Vendor.nexgen }
		'RiseRiseRise' { 'Rise Technology', Vendor.rise }
		'SiS SiS SiS ' { 'Silicon Integrated Systems', Vendor.sis }
		'UMC UMC UMC ' { 'United Microelectronics Corporation', Vendor.umc }
		'  Shanghai  ' { 'Zhaoxin', Vendor.zhaoxin }
		'HygonGenuine' { 'Hygone', Vendor.hygon }
		'bhyve bhyve ' { 'bhyve', Vendor.bhyve }
		' KVMKVMKVM  ' { 'Kernel-Based Virtual Machine', Vendor.kvm }
		'TCGTCGTCGTCG' { 'QEMU', Vendor.qemu }
		'Microsoft Hv' { 'Microsoft Hyper-V / Windows Virtual PC', Vendor.hyperv }
		'VMwareVMware' { 'VMware', Vendor.vmware }
		'XenVMMXenVMM' { 'Xen', Vendor.xenhvm }
		else { '<unknown>', Vendor.unknown }
	}
}
