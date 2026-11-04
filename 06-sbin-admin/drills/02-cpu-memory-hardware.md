# 06 - Sbin Admin: CPU, Memory and Hardware

Scenario: the same server, no documentation. How much machine is this, and is it under pressure?

1. `nproc`, `lscpu` and `/proc/cpuinfo` all gave a CPU count. What did each print?

On Ubuntu `nproc` printed 2, `lscpu` printed `CPU(s): 2`, and `grep -c ^processor /proc/cpuinfo` printed 2. On Rocky I ran `nproc` (2) and `lscpu` (2). I did not run `/proc/cpuinfo` on Rocky.

2. `free -h` showed `free` 246Mi and `available` 1.9Gi on Ubuntu. Which one tells me whether the machine is short of memory?

`available`. `free` was 246Mi and `MemAvailable` was 1967516 kB, so most of the memory that wasn't used was cache. I did not check what was using the 1.9Gi, because ps and top come later.

3. The second number in `/proc/uptime` grew by 9.94 in a 5 second sleep. What is it?

I think it is idle time added up over all CPUs. The first number grew by 5.01 and the machine has 2 CPUs, so the second grew by about twice that. The file doesn't label the field, so this is a fit and not a proof. I did not test it on a busy machine.

4. `strace` showed `openat(4, "cpuinfo")` with no full path. How do I know which directory fd 4 is, and what did my first filter miss?

Earlier in the trace `openat(AT_FDCWD, "/proc", ...) = 4`, so fd 4 was `/proc`. That is an inference from the trace, because I can't run `readlink` on the descriptor after `lscpu` has exited. My first filter looked for `/proc` and `/sys` as full paths, and a relative open prints only `"cpuinfo"`. I did not test whether `lscpu` takes the model name from `/proc/cpuinfo`.

5. Both VMs have 2 CPUs. What differed in `lscpu`?

The topology was the same: 1 thread per core and 1 core per socket. The model name differed: Ubuntu showed `Intel Atom Processor (Denverton)` with 40 bit physical addresses and model 95, Rocky showed `Intel(R) Core(TM) i7-10850H CPU @ 2.70GHz` with 39 bits and model 165. I did not look at the libvirt settings, so I don't know why. I also did not test why Rocky's `lsmem` total (4.3G) is further above its `MemTotal` (3873932 kB) than Ubuntu's (4G against 4005388 kB).

6. `dmesg | grep` printed nothing on Rocky, and bare `dmesg` printed an error. What does that teach about empty output?

The filter hid stderr. Bare `dmesg` printed `dmesg: read kernel buffer failed: Operation not permitted`. An empty result can mean nothing matched, the wrong place, or not allowed to look, so I run the command bare before trusting it.
