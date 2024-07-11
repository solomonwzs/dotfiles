#include <libproc.h>
#include <net/if_dl.h>
#include <netinet/tcp_fsm.h>
#include <sys/sysctl.h>

#include <vector>

int main(int argc, char **argv) {
  const char *ifname = argc > 1 ? argv[1] : nullptr;

  int mib[] = {CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST2, 0};
  size_t len;
  if (sysctl(mib, 6, nullptr, &len, nullptr, 0) < 0) {
    return -1;
  } else {
    std::vector<char> buf(len);
    if (sysctl(mib, 6, buf.data(), &len, nullptr, 0) < 0) {
      return -1;
    } else {
      char *lim = buf.data() + len;
      char *next = nullptr;
      for (next = buf.data(); next < lim;) {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;
        if (ifm->ifm_type == RTM_IFINFO2) {
          struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;
          struct sockaddr_dl *sdl = (struct sockaddr_dl *)(if2m + 1);
          char iface[32];
          strncpy(iface, sdl->sdl_data, sdl->sdl_nlen);
          iface[sdl->sdl_nlen] = 0;
          if (ifname != nullptr && strcmp(iface, ifname) != 0) {
            continue;
          }
          printf("%s %llu %llu\n", iface, if2m->ifm_data.ifi_ibytes,
                 if2m->ifm_data.ifi_obytes);
        }
      }
    }
  }

  return 0;
}
