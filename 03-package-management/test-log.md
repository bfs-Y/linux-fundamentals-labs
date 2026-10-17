## 03-A baseline - Fri Oct 16 07:10:28 AM CDT 2026
### Ubuntu: ownership

### Ubuntu: hold and break

### Ubuntu: fix

### Ubuntu: ownership (real output, Fri Oct 16 07:13:55 AM CDT 2026)
$ dpkg -S /usr/bin/ls
coreutils: /usr/bin/ls
$ dpkg -S /bin/ls
dpkg-query: no path found matching pattern /bin/ls
$ ls -ld /bin
lrwxrwxrwx 1 root root 7 Apr 22  2024 /bin -> usr/bin
$ dpkg -s coreutils | grep -E "Package|Version|Status"
Package: coreutils
Status: install ok installed
Version: 9.4-3ubuntu6.3
$ apt-cache policy gnome-shell-common
gnome-shell-common:
  Installed: 46.0-0ubuntu6~24.04.16
  Candidate: 46.0-0ubuntu6~24.04.16
  Version table:

### Ubuntu: hold and break
$ sudo apt install --only-upgrade gnome-shell
 gnome-shell : Depends: gnome-shell-common (= 46.0-0ubuntu6~24.04.16) but 46.0-0ubuntu6~24.04.15 is to be installed
E: Unable to correct problems, you have held broken packages.

### Ubuntu: fix
$ sudo apt-mark unhold gnome-shell-common
Canceled hold on gnome-shell-common.
2 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Status: install ok installed   (both gnome-shell and gnome-shell-common at .16)

### Rocky: hold and break
$ sudo dnf upgrade libsane-hpaio
 package libsane-hpaio-3.26.6-1.el10_2.3.x86_64 from appstream requires hplip-libs(x86-64) = 3.26.6-1.el10_2.3, but none of the providers can be installed
  - package hplip-libs-3.26.6-1.el10_2.3.x86_64 from appstream is filtered out by exclude filtering

### Comparison
| | Ubuntu | Rocky |
|---|---|---|
| Hold mechanism | apt-mark hold (built in) | versionlock plugin (install first) |
| Where stored | word in /var/lib/dpkg/status | /etc/dnf/plugins/versionlock.list |
| Error wording | held broken packages | filtered out by exclude filtering |
| Who/when | not recorded | timestamp, no user |

### Finding: who/when for a hold
- /var/lib/dpkg/status mtime = last dpkg transaction, NOT the hold time.
- Hold time and user come from: journalctl _COMM=sudo | grep apt-mark
- Hold placed Oct 15 09:22:07, removed Oct 16 06:58:33, both by ubuntulab.

### 03-B Ubuntu incident: nginx blocked by held nginx-common
$ sudo apt install nginx
 nginx : Depends: nginx-common (= 1.24.0-2ubuntu7.18) but 1.24.0-2ubuntu7 is to be installed
 nginx-common : Depends: nginx (< 1.24.0-2ubuntu7.1~) but 1.24.0-2ubuntu7.18 is to be installed
E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.
Evidence: apt-mark showhold -> nginx-common; apt-cache policy: Installed ubuntu7, Candidate .18.
Who/when: journalctl _COMM=sudo -> apt-mark hold nginx-common at 01:30:21 by ubuntulab.
Fix: sudo apt-mark unhold nginx-common; sudo apt install nginx -> 2 upgraded, 0 removed. showhold empty.

### Findings
- "held broken packages" appears even with NO hold (same error before and after unhold on the old-version install). Run apt-mark showhold first; empty means a version-pin conflict, not a hold.
- apt install pkg=version overrides a hold ("held packages will be changed").
- Three phrasings of one failure: "held broken packages", "pkgProblemResolver::Resolve generated breaks", dnf's "filtered out by exclude filtering".

### Rocky: ownership and lock state (Fri Oct 16 08:15:36 AM EDT 2026)
$ rpm -qf /usr/bin/ls
coreutils-9.5-8.el10_2.1.x86_64
$ rpm -qf /bin/ls
coreutils-9.5-8.el10_2.1.x86_64
$ ls -ld /bin
lrwxrwxrwx. 1 root root 7 Apr  1  2025 /bin -> usr/bin
$ cat /etc/dnf/plugins/versionlock.list
(0 bytes, mtime 08:09:36, one minute after the lock was added at 08:08:32)

### 03-B Rocky incident: ghostscript blocked by locked ghostscript-tools-fonts (Sat Oct 17 02:40:01 AM EDT 2026)
$ sudo dnf upgrade ghostscript
 package ghostscript-10.02.1-16.el10_2.3 requires ghostscript-tools-fonts = 10.02.1-16.el10_2.3, but none of the providers can be installed
 package ghostscript-tools-fonts-...el10_2.3 is filtered out by exclude filtering
$ cat /etc/dnf/plugins/versionlock.list (during incident)
 # Added lock on Sat Oct 17 02:36:09 2026
 ghostscript-tools-fonts-0:10.02.1-16.el10_2.1.*
Who/when: journalctl _COMM=sudo -> bfs ran dnf versionlock add at 02:35:28
Fix: dnf versionlock delete ghostscript-tools-fonts; dnf upgrade ghostscript -> Upgrade 4 Packages, no kernel
$ wc -c /etc/dnf/plugins/versionlock.list
0 /etc/dnf/plugins/versionlock.list
