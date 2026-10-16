## 03-A baseline - Fri Oct 16 07:10:28 AM CDT 2026
### Ubuntu: ownership
(paste dpkg -S /usr/bin/ls, dpkg -S /bin/ls, ls -ld /bin here)

### Ubuntu: hold and break
(paste apt-mark hold, the held broken packages error here)

### Ubuntu: fix
(paste unhold and the successful upgrade here)

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
