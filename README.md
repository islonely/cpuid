# CPUID
## Get information about the CPU in V
### Usage:

```v
import cpuid

const my_cpu = cpuid.info()

fn main() {
	// output: Intel(R) Core(TM) i5-8350U CPU @ 1.70GHz
	println(my_cpu.brand_name)
	// output: 8
	println(my_cpu.logical_cores)
}
```

### Public properties of `struct CPUInfo`:
```v
struct CPUInfo {
	manufacturer_id   string             // manufacturer id provided by the CPU
	brand_name        string = 'unknown' // Name used for marketing (Intel(R) Core(TM) i5-8350U CPU @ 1.70GHz)
	vendor            Vendor             // CPU vendor
	features          []Features         // features of the CPU
	physical_cores    int = -1           // Number of physical processor cores in your CPU.
	threads_per_core  int = 1            // Number of threads per physical core.
	logical_cores     int                // Number of physical cores multiplied by the amount of threads that can run on each core via hyperthreading.
	family            int                // CPU family number
	model             int                // CPU model number
	stepping          int                // CPU stepping info
	processor_type    ProcessorType
	freqency          int = -1           // Clock speed measured in MHz.
	boost_frequency   int = -1           // Max clock speed measured in MHz.
	bus_speed         int = -1           // Bus speed measured in MHz.
	caches            []Cache
	thermal_and_power struct {
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
```