#include <mach/mach.h>
#include <stdio.h>
#include <sys/sysctl.h>
#include <unistd.h>

int main(int argc, char **argv) {
  long pageSize = sysconf(_SC_PAGE_SIZE);

  int64_t memsize = 0;
  size_t size = sizeof(memsize);
  if (sysctlbyname("hw.memsize", &memsize, &size, nullptr, 0) < 0) {
    fprintf(stderr, "Could not get memory size");
  }
  long totalMem = memsize;

  vm_statistics64 p;
  mach_msg_type_number_t info_size = HOST_VM_INFO64_COUNT;
  if (host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&p, &info_size) == 0) {
    long free = p.free_count * pageSize;
    long cached = p.external_page_count * pageSize;
    long used = (p.active_count + p.wire_count) * pageSize;
    long available = totalMem - used;
    printf("%ld %ld %ld %ld %ld\n", free, cached, used, available, totalMem);
  }
  return 0;
}
