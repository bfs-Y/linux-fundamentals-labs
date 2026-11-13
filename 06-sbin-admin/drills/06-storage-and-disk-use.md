# 06 - Sbin Admin: Storage, Mounts and Disk Use

Scenario: the same server, no documentation. What disks does it have, what is mounted where, and what is eating the space?

1. `lsblk -e7` on both VMs: what is the layout, and where does `/` live?

Ubuntu: `vda` is 40G with `vda1` (1M) and `vda2` (40G), and `/` is on `vda2`, ext4. Rocky: `vda` is 40G with `vda1` (1M), `vda2` (1G, `/boot`) and `vda3` (39G), which holds `rl-root` (35G, `/`) and `rl-swap` (4G, `[SWAP]`).

2. Ubuntu `df` said 15G used, but the top-level `du` I printed added up to about 10.8G. What was missing?

`tail -n 8` had cut off `/swap.img`. `du -xsh /swap.img` printed 3.9G, and 10.8G plus 3.9G is about 14.7G, close to `df`. I did not check the last 0.3G.

3. Which swap does each VM use?

`swapon --show` printed `/swap.img` (file, 3.8G) on Ubuntu and `/dev/dm-1` (partition, 4G) on Rocky. Both showed 0B used on the last run, but earlier they showed 669.3M and 213.9M. I did not find out why it dropped. I did not test that `/dev/dm-1` is the `rl-swap` volume.

4. `2>/dev/null` hid errors in `du`. What did the bare run show?

At least six refusals, all under `/etc`, and `/root` was refused too, so its 4.0K is a floor. My guess that refusals explained the missing space was wrong, because the cause was `/swap.img`. I did not test what is inside the refused folders.

5. `/var` was the biggest folder on Ubuntu. What was inside it?

`/var` was 5.5G and `/var/lib` was 4.8G of it. Earlier, `/var/lib/snapd` was 4.5G of that. On the last run `/var/log` was 519M and `/var/cache` 207M, and earlier they were 541M and 173M, so they change between runs.
