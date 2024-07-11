#include <mach/mach.h>
#include <stdio.h>

#include <vector>

class MachProcessorInfo {
 public:
  processor_info_array_t info_array;
  mach_msg_type_number_t info_count;

  MachProcessorInfo() {}
  virtual ~MachProcessorInfo() {
    vm_deallocate(mach_task_self(),
                  (vm_address_t)info_array,
                  (vm_size_t)sizeof(processor_info_array_t) * info_count);
  }
};

int main(int argc, char **argv) {
  natural_t cpu_count;
  MachProcessorInfo info{};
  kern_return_t error;
  processor_cpu_load_info_data_t *cpu_load_info = nullptr;

  error = host_processor_info(
      mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpu_count, &info.info_array, &info.info_count);
  if (error != KERN_SUCCESS) {
    fprintf(stderr, "Failed getting CPU load info");
  }

  cpu_load_info = (processor_cpu_load_info_data_t *)info.info_array;
  long long all0 = 0;
  long long idle0 = 0;
  std::vector<std::pair<long long, long long>> cpu;
  for (natural_t i = 0; i < cpu_count; ++i) {
    long long all = cpu_load_info[i].cpu_ticks[CPU_STATE_USER]
        + cpu_load_info[i].cpu_ticks[CPU_STATE_NICE]
        + cpu_load_info[i].cpu_ticks[CPU_STATE_SYSTEM]
        + cpu_load_info[i].cpu_ticks[CPU_STATE_IDLE];
    long long idle = cpu_load_info[i].cpu_ticks[CPU_STATE_IDLE];
    cpu.push_back({idle, all});

    all0 += all;
    idle0 += idle;
  }
  printf("%lld %lld\n", idle0, all0);
  for (auto &i : cpu) {
    printf("%lld %lld\n", i.first, i.second);
  }
  return 0;
}
