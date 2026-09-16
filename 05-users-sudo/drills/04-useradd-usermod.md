# Drill 04 — useradd and usermod flags

Critical flags to know:

useradd -m username
  -m creates home directory — without it user has no /home/username

usermod -aG sudo username
  -a appends to groups — without -a all existing groups are replaced silently
  -G specifies the group to add

userdel -r username
  -r removes home directory — without it files remain on disk after account deletion

Always verify after changes:
id username
ls /home/username
