# 06 - Sbin Admin: Storage, Mounts and Disk Use

Scenario: the same server, no documentation. What disks does it have, what is mounted where, and what is eating the space?

1. `lsblk -e7` on both VMs: what is the layout, and where does `/` live?

Ubuntu uses a 40G virtual disk, `vda`, with `vda1` (1M) and `vda2` (40G), and `/` is mounted on `vda2`. The filesystem is ext4, confirmed by `df -hT`, not `lsblk -e7`. Rocky has a separate `/boot` partition, `vda2` (1G), and uses LVM for its root and swap volumes: `rl-root` (35G, `/`) and `rl-swap` (4G, `[SWAP]`) inside `vda3` (39G). I did not verify Rocky's filesystem types in this investigation.

2. Ubuntu `df` said 15G used, but the top-level `du` I printed added up to about 10.8G. What was missing?

`tail -n 8` on Ubuntu's top-level `du` output cut off `/swap.img`, which was a single 3.9G file. The command `du -xsh /swap.img /opt /srv /root` exposed it. The visible directories totalled approximately 10.8G; adding the swap file gives approximately 14.7G, close to the 15G reported by `df -hT`. I did not account for the remaining 0.3G. Separately, used plus available is about 2 GiB short of the 40G total because of the root reserve, see `drills/df.md`.

3. Which swap does each VM use?

Ubuntu uses `/swap.img`, type `file`, 3.8G. Rocky uses `/dev/dm-1`, type `partition`, 4G. `ls -l /dev/mapper` showed `rl-swap -> ../dm-1`, so Rocky's swap is the `rl-swap` volume. I did not test why swap usage changed from 669.3M to 0B on Ubuntu and from 213.9M to 0B on Rocky.

4. `2>/dev/null` hid errors in `du`. What did the bare run show?

The bare `du` run printed at least six permission-denied messages, all under `/etc`, including `credstore`, `sssd`, `cups/ssl` and `ssl/private`. `head -n 6` cut the list, so there may be more. `/root` was refused too, so its 4.0K is a floor, not a size. These refusals did not explain the gap, because `/swap.img` accounted for most of it. I did not test the contents and actual disk usage of `/root` or `/etc/ssl/private`.

5. `/var` was the biggest folder on Ubuntu. What was inside it?

`/var` used 5.5G, with `/var/lib` the largest folder inside it at 4.8G. Inside `/var/lib`, `snapd` was the largest at 4.5G, compared with `apt` at 218M and `dpkg` at 64M. `/var/log` was 519M and `/var/cache` 207M on the last run, and 541M and 173M earlier. I did not test what specifically inside `snapd` accounted for the 4.5G, or why `/var/log` and `/var/cache` changed between runs.
