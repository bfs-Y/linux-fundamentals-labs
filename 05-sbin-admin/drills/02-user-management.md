# Drill 02: User Management

Time: 8 minutes

## What You're Doing

Using /sbin tools to manage users on the system.

## Start Container
```bash
docker run -it --rm ubuntu:22.04 /bin/bash
```

## Create a User
```bash
useradd -m alice
```

The `-m` creates home directory at /home/alice

Check it worked:
```bash
id alice
ls -ld /home/alice
```

## Set Password
```bash
passwd alice
```

Enter password twice when prompted.

Or non-interactive:
```bash
echo "alice:password123" | chpasswd
```

## Check User Info
```bash
cat /etc/passwd | grep alice
```

Shows: alice:x:1000:1000::/home/alice:/bin/sh

Breakdown:
- alice = username
- x = password in /etc/shadow (encrypted)
- 1000 = user ID (UID)
- 1000 = group ID (GID)
- /home/alice = home directory
- /bin/sh = default shell

## Modify User

Change shell:
```bash
usermod -s /bin/bash alice
cat /etc/passwd | grep alice
```

Now shows /bin/bash as shell.

Add to sudo group:
```bash
usermod -aG sudo alice
```

The `-aG` = append to group (doesn't remove other groups).

Check groups:
```bash
groups alice
```

## Create User with Specific UID
```bash
useradd -m -u 2000 bob
id bob
```

Bob has UID 2000 instead of default 1001.

## Delete User
```bash
userdel alice
```

Removes user but leaves home directory.

Check:
```bash
ls -ld /home/alice
```

Still exists.

Remove user AND home:
```bash
userdel -r bob
ls -ld /home/bob
```

Gone. Home directory deleted.

## Group Management

Create group:
```bash
groupadd developers
```

Add user to group:
```bash
useradd -m charlie
usermod -aG developers charlie
groups charlie
```

Delete group:
```bash
groupdel developers
```

## Audit Users

See all users:
```bash
cat /etc/passwd
```

See only regular users (UID >= 1000):
```bash
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```

Check who can login:
```bash
cat /etc/passwd | grep -v nologin
```

## Security Check

Users with UID 0 (root):
```bash
awk -F: '$3 == 0 {print $1}' /etc/passwd
```

Should only show "root". If others exist, they have root powers.

Users with empty passwords:
```bash
awk -F: '$2 == "" {print $1}' /etc/shadow
```

Should be empty. Empty password = anyone can login.

## Exit
```bash
exit
```

## Key Commands
```
useradd -m username    # Create with home dir
passwd username        # Set password
usermod -s /bin/bash   # Change shell
usermod -aG group      # Add to group
userdel -r username    # Delete with home
groupadd groupname     # Create group
```

## Key Files

/etc/passwd - User info (public)
/etc/shadow - Encrypted passwords (root only)
/etc/group - Group memberships
