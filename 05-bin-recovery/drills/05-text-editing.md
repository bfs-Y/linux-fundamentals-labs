# Drill 05: Text Editing Without vim

Time: 7 minutes

## Scenario

Emergency shell. You need to fix `/etc/fstab` to correct a mount point.

vim isn't there. nano isn't there. Now what?

## Setup
```bash
docker run -it --rm --privileged alpine:3.19 /bin/sh

cat > /tmp/config.txt << 'EOF'
service=apache
port=80
enabled=true
EOF

mv /usr /usr.backup
mkdir /usr
```

## The Problem
```bash
vim /tmp/config.txt
# not found

nano /tmp/config.txt  
# not found
```

You only have what's in `/bin`.

## Option 1: vi

Check if it exists:
```bash
ls /bin/vi
```

If you're lucky:
```bash
vi /tmp/config.txt
```

Survival vi:
- `i` - start typing
- `ESC` - stop typing
- `:wq` - save and quit
- `:q!` - quit without saving

## Option 2: sed

Change port 80 to 8080:
```bash
sed -i 's/port=80/port=8080/' /tmp/config.txt
cat /tmp/config.txt
```

Change service name:
```bash
sed -i 's/service=apache/service=nginx/' /tmp/config.txt
```

Delete a line:
```bash
sed -i '/enabled=true/d' /tmp/config.txt
```

## Option 3: Rewrite with echo

See what's there:
```bash
cat /tmp/config.txt
```

Rewrite it:
```bash
cat > /tmp/config.txt << 'EOF'
service=nginx
port=8080
enabled=false
EOF
```

Add a line:
```bash
echo "timeout=30" >> /tmp/config.txt
```

## Real Example

Fix wrong device in `/etc/fstab`:
```bash
cat /etc/fstab
sed -i 's|/dev/sda3|/dev/sda2|' /etc/fstab
cat /etc/fstab
```

## Exit
```bash
exit
```

## Point

You can't count on vim being there.

sed for find-replace. echo for appending. cat with heredoc for rewrites.

Editing files without opening an editor is a real skill.
