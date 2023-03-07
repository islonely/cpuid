module cpuid

import strings

pub const info = cpu()

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
	nexgen
	rise
	umc
	zhaoxin
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

// Feature
pub enum Feature {
	unknown = -1
	fpu // Onboard x87 FPU
	vme // Virtual 8086 mode extenstions (such as VIF, VIP, PIV)
	de // Debugging extensions (CR4 bit 3)
	pse // Page Size Extension
	tsc // Time Stamp Counter
	msr // Mode-specific registers
	pae // Physical Address Extension
	mce // Machine Check Exception
	cx8 // CMPXCHG8 (compare-and-swap) instruction
	apic // Onboard Advanced Programmable Interrupt Controller
	sep // SYSENTER and SYSEXIT instructions
	mtrr // Memory Type Range Registers
	pge // Page Global Enable bit in CR4
	mca // Machine check architecture
	cmov // Conditional move and FCMOV instructions
	pat // Page Attribute Table
	pse_36 // 36-bit page size extension
	psn // Processor Serial Number
	clfsh // CLFLUSH instruction (SSE2)
	ds // Debug store: save trace of executed jumps
	acpi // Onboard thermal control MSRs for ACPI
	mmx // MMX instructions
	fxsr // FXSAVE, FXRESTOR instructions, CR4 bit 9
	sse // SSE instructions (a.k.a. Katmai New Instructions)
	sse2 // SSE2 instructions
	ss // CPU cache implements self-snoop
	htt // Hyper-threading
	tm // Thermal monitor automatically limits temperature
	ia64 // IA64 processor emulating x86
	pbe // Pending Break Enable (PBE# pin) wakeup capability
	sse3 // Prescott new Instructions-SSE3 (PNI)
	pclmulqdq // PCLMULQDQ
	dtes64 // 64-bit debug store (edx bit 21)
	monitor // MONITOR and MWAIT instructions (SSE3)
	ds_cpl // CPL qualified debug store
	vmx // Virtual Machine eXtensions
	smx // Safer Mode Extensions (LaGrande)
	est // Enhanced SpeedStep
	tm2 // Thermal Monitor 2
	ssse3 // Supplemental SSE3 instructions
	cnxt_id // L1 Context ID
	sdbg // Silicon Debug interface
	fma // Fused multiply-add (FMA3)
	cx16 // CMPXCHG16B instruction
	xtpr // Can disable sending task priority messages
	pdcm // Perfmon & debug capability
	pcid // Process context identifiers (CR4 bit 17)
	dca // Direct cache access for DMA writes
	sse4_1 // SSE4.1 instructions
	sse4_2 // SSE4.2 instructions
	x2apic // x2APIC
	movbe // MOVBE instruction (big-endian)
	popcnt // POPCNT instruction
	tsc_deadline // APIC implements one-shot operation using a TSC deadline value
	aes // AES instruction set
	xsave // XSAVE, XRESTOR, XSETBV, XGETBV
	osxsave // XSAVE enabled by OS
	avx // Advanced Vector Extensions
	f16c // F16C (half-precision) FP feature
	rdrnd // RDRAND (on-chip random number generator) feature
	hypervisor // Hypervisor present (always zero on physical CPUs)
	count
}

// ProcessorType
pub enum ProcessorType {
	unknown = -1
	oem
	intel_overdrive
	dual_processor
	reserved
	count
}

// CPUInfo contains information about the detected system CPU.
struct CPUInfo {
mut:
	max_eax_val int
pub mut:
	manufacturer_id  string    // manufacturer id provided by the CPU
	brand_name       string    // brand name generated from CPU manufacturer ID
	vendor           Vendor    // vendor
	features         []Feature // features of the CPU
	physical_cores   int       // Number of physical processor cores in your CPU. Will be 0 if undetectable
	threads_per_core int = 1 // Number of threads per physical core. Will be 1 if undetectable.
	logical_cores    int       // Number of physical cores times threads that can run on each core through the use of hyperthreading. Will be 0 if undetectable.
	family           int       // CPU family number
	model            int       // CPU model number
	stepping         int       // CPU stepping info
	processor_type   ProcessorType
	freqency         i64 // Clock speed, if known, 0 otherwise. Will attempt to contain base clock speed.
	boost_frequency  i64 // Max clock speed, if known, 0 otherwise.
	caches           []Cache
}

// cpu will detect current CPU info and return it.
pub fn cpu() CPUInfo {
	mut cpu := CPUInfo{}
	leaf0(mut cpu)
	leaf1(mut cpu)
	leaf2(mut cpu)
	// leaf3 gets processor serial number. This is not used on modern CPUs
	leaf4(mut cpu)
	return cpu
}

// leaf0 sets the CPU brand name and Vendor
fn leaf0(mut cpu CPUInfo) {
	mut vendor_bldr := strings.new_builder(12)
	regs := asm_cpuid(eax: 0)
	vendor_bldr.write_string(regs.stringify('b'))
	vendor_bldr.write_string(regs.stringify('d'))
	vendor_bldr.write_string(regs.stringify('c'))
	cpu.manufacturer_id = vendor_bldr.str()

	// Vendor set based off of this:
	// https://en.wikipedia.org/wiki/CPUID
	cpu.brand_name, cpu.vendor = match cpu.manufacturer_id {
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

	cpu.max_eax_val = int(regs.eax)
}

// leaf1 sets processor info and features
fn leaf1(mut cpu CPUInfo) {
	if cpu.max_eax_val < 1 {
		return
	}

	regs := asm_cpuid(eax: 1)
	// EAX - Processor Version Information
	{
		cpu.stepping = get_bits(regs.eax, 0, 4)
		model := get_bits(regs.eax, 4, 4)
		family := get_bits(regs.eax, 8, 4)
		processor_type := get_bits(regs.eax, 12, 2)
		model_ext := get_bits(regs.eax, 16, 4)
		family_ext := get_bits(regs.eax, 20, 8)

		cpu.model = if family in [6, 15] {
			(model_ext << 4) + model
		} else {
			model
		}

		cpu.family = if family == 15 {
			family + family_ext
		} else {
			family
		}

		cpu.processor_type = match processor_type {
			0b00 { ProcessorType.oem }
			0b01 { ProcessorType.intel_overdrive }
			0b10 { ProcessorType.dual_processor }
			0b11 { ProcessorType.reserved }
			else { ProcessorType.unknown }
		}
	}
	// EDX, ECX - Feature Information
	{
		db := u32_to_bits(regs.edx)
		cb := u32_to_bits(regs.ecx)
		// Adam says: this is absolutely stupid, but I'm not seeing a proper way to put this in a loop
		// withouth also making multiple enums which is also stupid.
		// vfmt off
		if db[0] { cpu.features << .fpu }
		if db[1] { cpu.features << .vme }
		if db[2] { cpu.features << .de }
		if db[3] { cpu.features << .pse }
		if db[4] { cpu.features << .tsc }
		if db[5] { cpu.features << .msr }
		if db[6] { cpu.features << .pae }
		if db[7] { cpu.features << .mce }
		if db[8] { cpu.features << .cx8 }
		if db[9] { cpu.features << .apic }
		if db[11] { cpu.features << .sep }
		if db[12] { cpu.features << .mtrr }
		if db[13] { cpu.features << .pge }
		if db[14] { cpu.features << .mca }
		if db[15] { cpu.features << .cmov }
		if db[16] { cpu.features << .pat }
		if db[17] { cpu.features << .pse_36 }
		if db[18] { cpu.features << .psn }
		if db[19] { cpu.features << .clfsh }
		if db[21] { cpu.features << .ds }
		if db[22] { cpu.features << .acpi }
		if db[23] { cpu.features << .mmx }
		if db[24] { cpu.features << .fxsr }
		if db[25] { cpu.features << .sse }
		if db[26] { cpu.features << .sse2 }
		if db[27] { cpu.features << .ss }
		if db[28] { cpu.features << .htt }
		if db[29] { cpu.features << .tm }
		if db[30] { cpu.features << .ia64 }
		if db[31] { cpu.features << .pbe }

		if cb[0] { cpu.features << .sse3 }
		if cb[1] { cpu.features << .pclmulqdq }
		if cb[2] { cpu.features << .dtes64 }
		if cb[3] { cpu.features << .monitor }
		if cb[4] { cpu.features << .ds_cpl }
		if cb[5] { cpu.features << .vmx }
		if cb[6] { cpu.features << .smx }
		if cb[7] { cpu.features << .est }
		if cb[8] { cpu.features << .tm2 }
		if cb[9] { cpu.features << .ssse3 }
		if cb[10] { cpu.features << .cnxt_id }
		if cb[11] { cpu.features << .sdbg }
		if cb[12] { cpu.features << .fma }
		if cb[13] { cpu.features << .cx16 }
		if cb[14] { cpu.features << .xtpr }
		if cb[15] { cpu.features << .pdcm }
		if cb[17] { cpu.features << .pcid }
		if cb[18] { cpu.features << .dca }
		if cb[19] { cpu.features << .sse4_1 }
		if cb[19] { cpu.features << .sse4_2 }
		if cb[21] { cpu.features << .x2apic }
		if cb[22] { cpu.features << .movbe }
		if cb[23] { cpu.features << .popcnt }
		if cb[24] { cpu.features << .tsc_deadline }
		if cb[25] { cpu.features << .aes }
		if cb[26] { cpu.features << .xsave }
		if cb[27] { cpu.features << .osxsave }
		if cb[28] { cpu.features << .avx }
		if cb[29] { cpu.features << .f16c }
		if cb[30] { cpu.features << .rdrnd }
		if cb[31] { cpu.features << .hypervisor }
		// vfmt on
	}
	// EBX - Additional Information
	{
		// cache line size can now be accessed by CPUInfo.caches[0].line_size
		// ebx_bytes := u32_to_bytes(regs.ebx)
		// cpu.cache.line_size = ebx_bytes[1]
	}
}

// leaf2 sets some CPU cache/TLB information
fn leaf2(mut cpu CPUInfo) {
	if cpu.vendor != .intel {
		return
	}
	if cpu.max_eax_val < 2 {
		return
	}

	regs := asm_cpuid(eax: 2)
	// pretty sure this should be used for older intel CPUs only
}

// leaf4 sets CPU cache information
fn leaf4(mut cpu CPUInfo) {
	if cpu.vendor != .intel {
		return
	}
	if cpu.max_eax_val < 4 {
		return
	}

	mut cache_id := u32(0)
	for {
		regs := asm_cpuid(eax: 4, ecx: cache_id)
		cache_id++
		cache_type_u32 := regs.eax & 0xf
		if cache_type_u32 == 0 {
			break
		}

		cache_type := if cache_type_u32 >= u32(CacheType.count) {
			CacheType.unknown
		} else {
			unsafe { CacheType(cache_type_u32) }
		}

		cache_level_u32 := (regs.eax >> 5) & 0x7
		// self_init_cache_level_uint := regs.eax & (1 << 8)
		// fully_associative_cache_uint := regs.eax & (1 << 9)
		// max_num_logical_core_sharing_uint := (regs.eax >> 14) & 0x3ff
		// max_num_physical_cores_uint := (regs.eax >> 26) & 0x3f
		system_coherency_line_size_u32 := (regs.ebx & 0xFFF) + 1
		physical_line_partitions_u32 := (regs.ebx >> 12) & 0x3FF + 1
		ways_of_associativity_u32 := (regs.ebx >> 22) & 0x3FF + 1
		number_of_sets_u32 := regs.ecx + 1
		// write_back_invalidate_uint := regs.edx & 1
		// cache_inclusiveness_uint := regs.edx & (1 << 1)
		// complex_cache_indexing_uint := regs.edx & (1 << 2)
		cache_size_u32 := (ways_of_associativity_u32 * physical_line_partitions_u32 * system_coherency_line_size_u32 * number_of_sets_u32) >> 10

		cache_level := if cache_level_u32 >= u32(CacheLevel.count) {
			CacheLevel.unknown
		} else {
			unsafe { CacheLevel(cache_level_u32) }
		}

		cpu.caches << Cache{
			level: cache_level
			@type: cache_type
			size: int(cache_size_u32)
			ways: int(ways_of_associativity_u32)
			line_size: int(system_coherency_line_size_u32)
			entries: int(number_of_sets_u32)
			partitions: int(physical_line_partitions_u32)
		}
	}
}
