#!/bin/bash
# Recovery procedure for /usr mount failure

echo "[*] Emergency Shell Recovery Procedure"
echo ""

echo "Step 1: Verify the problem"
echo "  ls /usr/bin"
echo "  Expected: empty or 'No such file or directory'"
echo ""

echo "Step 2: Check what should be mounted"
echo "  cat /etc/fstab | grep /usr"
echo "  Expected: /dev/sdaX /usr ext4 ..."
echo ""

echo "Step 3: Attempt mount"
echo "  mount /dev/sdaX /usr"
echo "  Or in our sim: mount /usr.backup /usr"
echo ""

echo "Step 4: Verify recovery"
echo "  ls /usr/bin | wc -l"
echo "  Expected: 100+ binaries"
echo ""

echo "Step 5: Test critical tools"
echo "  vi --version"
echo "  find --help"
echo ""

echo "[*] If mount fails, check:"
echo "  - dmesg | grep -i error"
echo "  - Filesystem corruption (may need fsck)"
echo "  - Wrong device specified"
