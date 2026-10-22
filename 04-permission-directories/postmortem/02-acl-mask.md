# Postmortem: chmod 600 silently blocked an ACL reader

Date: 2026-10-21. Ubuntu 24.04 and Rocky 10.

A file gave `labreader` read access through an ACL entry. A "tighten the permissions" step ran `chmod 600`, and `labreader` was blocked even though `ls -l` showed a normal `-rw-------+` file.

On a file with an ACL, the group bits in `chmod` set the mask, which caps named-user and group entries. `chmod 600` made the mask `---`, so `labreader`'s `r--` showed `#effective:---`.

I found it from the `+` in `ls -l`, then `getfacl`. The fix was `setfacl -m m::r--`. It worked the same on both distros.

For whoever takes over: when you see `+` in `ls -l`, run `getfacl` before concluding anything, and don't use `chmod` on a file whose access comes from an ACL.
