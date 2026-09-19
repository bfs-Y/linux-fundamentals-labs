# Postmortem — SSH refused after reboot (unplanned)

**Root cause:** `openssh-server` was never installed on this VM. Fully
unrelated to the GRUB revert, the reboot, or the QEMU display glitch
that occurred at the same time - a pre-existing gap that happened to
surface at the exact moment SSH access was needed.

**Detection method:** Ruled out causes in order, using host-side
evidence before touching the guest: `virsh list --all` confirmed the VM
was running (not crashed); `virsh domifaddr` confirmed a live IP;
`ssh ... -> Connection refused` (not a timeout - meaningfully different,
implies port reachable but nothing listening); `virsh dominfo` compared
twice showed advancing CPU time (VM not frozen); graphical console via
`virt-viewer` confirmed a normal, fully-booted desktop. Root cause was
only found once inside the VM via console: `systemctl status ssh`
returned "Unit ssh.service could not be found," confirmed by
`dpkg -l | grep openssh-server` returning nothing.

**Time to resolution:** Slower than it should have been - initial
instinct was to assume the reboot had broken something ("it won't be
booted"), which was wrong and nearly led to skipping the actual
diagnostic chain. Correct root cause was only reached by methodically
ruling out VM-crashed, VM-hung, and display-broken before considering
"the service was never there at all."

**One thing to do differently:** Don't default to blaming the most
recent change (the GRUB edit/reboot) when a new symptom appears at the
same time - "Connection refused" specifically (vs. timeout or no route
to host) should have been the immediate signal to check whether a
listener existed at all, before spending time ruling out crash/hang
scenarios that a refused-not-timed-out connection had already made
unlikely.
