module cpuid

[params]
struct CPUIDParams {
	eax u32  [required]
	ecx ?u32
}

// asm_cpuid executes the cpuid assembly instruction with the
// specified values sent to registers eax and ecx (if used).
fn asm_cpuid(params CPUIDParams) Registers {
	mut info_type := params.eax
	mut regs := Registers{}
	if extended := params.ecx {
		asm amd64 {
			mov eax, info_type
			mov ecx, extended
			cpuid
			; =a (regs.eax) as eax0
			  =b (regs.ebx) as ebx0
			  =d (regs.edx) as edx0
			  =c (regs.ecx) as ecx0
			; r (info_type)
			  r (extended)
		}
	} else {
		asm amd64 {
			mov eax, info_type
			cpuid
			; =a (regs.eax) as eax0
			  =b (regs.ebx) as ebx0
			  =d (regs.edx) as edx0
			  =c (regs.ecx) as ecx0
			; r (info_type)
		}
	}
	return regs
}
