# 06 - Sbin Admin: Storage, Mounts and Disk Use

Scenario: the same server, no documentation. What disks does it have, what is mounted where, and what is eating the space?

1. `lsblk -e7` on both VMs: what is the layout of each disk, and where does `/` live?

Ubuntu: `vda` is 40G with `vda1` (1M) and `vda2` (40G), and `/` is on `vda2`, ext4. Rocky: `vda` is 40G with `vda1` (1M), `vda2` (1G, `/boot`) and `vda3` (39G), which holds the LVM volumes `rl-root` (35G, `/`, xfs) and `rl-swap` (4G, swap).

2. Ubuntu `df` said 15G used, but the top-level `du` I printed added up to about 10.8G. What was missing?

`tail -n 8` had cut off `/swap.img`. `du -xsh /swap.img` printed 3.9G, and 10.8G plus 3.9G is about 14.7G, close to `df`. I did not check the last 0.3G.

3. Which swap does each VM use?

`swapon --show` listed `/swap.img` (file, 3.8G, 669.3M used) on Ubuntu and `/dev/dm-1` (partition, 4G, 213.9M used) on Rocky. I did not test that `/dev/dm-1` is the `rl-swap` volume.

4. `2>/dev/null` hid errors in `du`. What did the bare run show, and what does that teach?

It printed at least six refusals, all under `/etc` (`credstore`, `credstore.encrypted`, `polkit-1/rules.d`, `sssd`, `cups/ssl`, `ssl/private`), and `/root` was refused too, so its 4.0K is a floor. My guess that refused folders explained the missing space was wrong. The cause was `/swap.img`. I did not test what is inside the refused folders.

5. `/var` was the biggest folder on Ubuntu. What was inside it?

`/var` was 5.5G and `/var/lib` was 4.8G of it. Inside `/var/lib`, `snapd` was 4.5G, `apt` 218M and `dpkg` 64M. `/var/log` was 541M and `/var/cache` 173M.

6. Rocky's `df` said 5.8G used on `/` and `du` said 5.0G. What can I say?

Only that they differ by about 0.8G. I hid the `du` errors with `2>/dev/null` and never ran it bare on Rocky, so I did not test why.
