module cpuid

import strings
import regex

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
	max_eax_val     u32
	max_ext_eax_val u32
pub mut:
	manufacturer_id   string // manufacturer id provided by the CPU
	brand_name        string = 'unknown'
	vendor            Vendor    // vendor
	features          []Feature // features of the CPU
	physical_cores    int = -1 // Number of physical processor cores in your CPU. Will be -1 if undetectable
	threads_per_core  int = 1 // Number of threads per physical core. Will be 1 if undetectable.
	logical_cores     int       // Number of physical cores times threads that can run on each core through the use of hyperthreading. Will be 0 if undetectable.
	family            int       // CPU family number
	model             int       // CPU model number
	stepping          int       // CPU stepping info
	processor_type    ProcessorType
	freqency          int = -1 // Clock speed measured in MHz. Will be -1 if undetectable.
	boost_frequency   int = -1 // Max clock speed measured in MHz. Will be -1 if undetectable.
	bus_speed         int = -1 // Bus speed measured in MHz. Will be -1 if undetectable.
	caches            []Cache
	thermal_and_power struct {
	pub mut:
		has_dts  bool // digital thermal sensor
		has_itbt bool // intel turb boost technology
		has_arat bool // always running APIC timer
		has_pln  bool // power limit notification
		has_ecmd bool // extended clock modulation duty
		has_ptm  bool // package thermal management
		has_hcf  bool // hardware coordination feedback
		has_peb  bool // performance-energy bias
	}
}

// info will detect current CPU info and return it.
pub fn info() CPUInfo {
	mut cpu := CPUInfo{}
	cpu.leaf0()
	cpu.leaf1()
	cpu.leaf2()
	// leaf3 gets processor serial number. This is not used on modern CPUs
	asm_cpuid(eax: 3)
	cpu.leaf4()
	cpu.leaf6()
	cpu.leaf0xb()
	cpu.leaf0x80000000()
	// leaf 0x80000002 must come before leaf 16 if leaf 0x15 is unavailable.
	// But also, leaf 0x80000002 doesn't work if it's moved above leaf 0x80000000
	cpu.leaf0x80000002()
	cpu.leaf0x16()
	return cpu
}

// leaf0 sets the CPU brand name and Vendor
fn (mut cpu CPUInfo) leaf0() {
	mut vendor_bldr := strings.new_builder(12)
	regs := asm_cpuid(eax: 0)
	vendor_bldr.write_string(regs.stringify('b'))
	vendor_bldr.write_string(regs.stringify('d'))
	vendor_bldr.write_string(regs.stringify('c'))
	cpu.manufacturer_id = vendor_bldr.str()

	// Vendor set based off of this:
	// https://en.wikipedia.org/wiki/CPUID
	cpu.vendor = match cpu.manufacturer_id {
		'AMDisbetter!', 'AuthenticAMD' { Vendor.amd }
		'CentaurHauls', 'VIA VIA VIA ' { Vendor.via }
		'CyrixInstead' { Vendor.ibm }
		'GenuineIntel' { Vendor.intel }
		'TransmetaCPU', 'GenuineTMx86' { Vendor.transmeta }
		'Geode by NSC' { Vendor.nsc }
		'NexGenDriven' { Vendor.nexgen }
		'RiseRiseRise' { Vendor.rise }
		'SiS SiS SiS ' { Vendor.sis }
		'UMC UMC UMC ' { Vendor.umc }
		'  Shanghai  ' { Vendor.zhaoxin }
		'HygonGenuine' { Vendor.hygon }
		'bhyve bhyve ' { Vendor.bhyve }
		' KVMKVMKVM  ' { Vendor.kvm }
		'TCGTCGTCGTCG' { Vendor.qemu }
		'Microsoft Hv' { Vendor.hyperv }
		'VMwareVMware' { Vendor.vmware }
		'XenVMMXenVMM' { Vendor.xenhvm }
		else { Vendor.unknown }
	}

	cpu.max_eax_val = regs.eax
}

// leaf1 sets processor info and features
fn (mut cpu CPUInfo) leaf1() {
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
fn (mut cpu CPUInfo) leaf2() {
	if cpu.vendor != .intel {
		return
	}
	if cpu.max_eax_val < 2 {
		return
	}

	regs := asm_cpuid(eax: 2)
	// TODO: pretty sure this should be used for older intel CPUs only
}

// leaf3 sets CPU serial number for processors Pentium 4 and earlier
fn (mut cpu CPUInfo) leaf3() {
	if cpu.max_eax_val < 3 || cpu.vendor != .intel {
		return
	}
	// TODO: implement this
}

// leaf4 sets CPU cache information
fn (mut cpu CPUInfo) leaf4() {
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

// leaf6 sets CPU thermal and power information
fn (mut cpu CPUInfo) leaf6() {
	if cpu.max_eax_val < 6 {
		return
	}

	regs := asm_cpuid(eax: 6)
	dts := get_bits(regs.eax, 0, 1)
	itbt := get_bits(regs.eax, 1, 1)
	arat := get_bits(regs.eax, 2, 1)
	pln := get_bits(regs.eax, 4, 1)
	ecmd := get_bits(regs.eax, 5, 1)
	ptm := get_bits(regs.eax, 6, 1)
	hcf := get_bits(regs.ecx, 0, 1)
	peb := get_bits(regs.ecx, 3, 1)
	cpu.thermal_and_power.has_dts = if dts > 0 { true } else { false }
	cpu.thermal_and_power.has_itbt = if itbt > 0 { true } else { false }
	cpu.thermal_and_power.has_arat = if arat > 0 { true } else { false }
	cpu.thermal_and_power.has_pln = if pln > 0 { true } else { false }
	cpu.thermal_and_power.has_ecmd = if ecmd > 0 { true } else { false }
	cpu.thermal_and_power.has_ptm = if ptm > 0 { true } else { false }
	cpu.thermal_and_power.has_hcf = if hcf > 0 { true } else { false }
	cpu.thermal_and_power.has_peb = if peb > 0 { true } else { false }
}

// leaf0x16 sets the CPU frequency, boost frequency, and bus speed.
fn (mut cpu CPUInfo) leaf0x16() {
	if cpu.max_eax_val >= 0x15 {
		regs := asm_cpuid(eax: 0x15)
		if 0 !in [regs.eax, regs.ebx, regs.ecx] {
			cpu.freqency = int(i64(regs.ecx) * i64(regs.ebx) / i64(regs.eax) / 1_000_000)
		}
	}
	if cpu.max_eax_val >= 0x16 {
		regs := asm_cpuid(eax: 0x16)
		// base clock
		if regs.eax & 0xffff > 0 {
			cpu.freqency = int(regs.eax & 0xffff)
		}

		// boost clock
		if regs.ebx & 0xffff > 0 {
			cpu.boost_frequency = int(regs.ebx & 0xffff)
		}
	}
	if cpu.freqency != -1 {
		return
	}
}

// leaf0xb sets CPU core information.
fn (mut cpu CPUInfo) leaf0xb() {
	if cpu.max_eax_val < 0xb {
		return
	}

	regs := asm_cpuid(eax: 0x0b, ecx: 1)
	cpu.logical_cores = get_bits(regs.ebx, 0, 16)
	cpu.physical_cores = if Feature.htt in cpu.features {
		cpu.logical_cores / 2
	} else {
		cpu.logical_cores
	}
	cpu.threads_per_core = cpu.logical_cores / cpu.physical_cores
}

// leaf0x80000000 sets the max extended input value for the CPUID instruction.
fn (mut cpu CPUInfo) leaf0x80000000() {
	regs := asm_cpuid(eax: 0x80000000)
	cpu.max_ext_eax_val = regs.eax
}

// leaf0x80000002 sets the CPU brand name.
fn (mut cpu CPUInfo) leaf0x80000002() {
	if cpu.max_ext_eax_val < 0x80000004 {
		return
	}

	mut brand_name_bytes := []u8{cap: 48}
	for i := u32(0); i < 3; i++ {
		regs := asm_cpuid(eax: 0x80000002 + i)
		brand_name_bytes << regs.bytes()
	}
	cpu.brand_name = brand_name_bytes.bytestr()
}

// fn leaf0x80000008(mut cpu CPUInfo) {
// 	if cpu.max_ext_eax_val < 0x80000008 {
// 		return
// 	}
//
// 	regs := asm_cpuid(eax: 0x80000008)
// }
