

Date: 2026-09-17

## 1. Command resolution: alias vs function vs $PATH binary

$ type ls          (Ubuntu & Rocky)
ls is aliased to `ls --color=auto'

$ which ls          (Rocky)
alias ls='ls --color=auto'
	/usr/bin/ls

$ type -a which     (Fedora)
which is aliased to `(alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot'
which is /usr/bin/which

$ (alias; declare -f) | grep '^alias ls='
alias ls='ls --color=auto'

$ type -a alias     (Ubuntu)
alias is a shell builtin

$ type -a alias     (Rocky)
alias is a shell builtin
alias is /usr/bin/alias

$ rpm -qf /usr/bin/alias   (Rocky)
bash-5.2.26-6.el10.x86_64

## 2. Resolution order proof: alias > function > external binary

$ greet() { echo "function version"; }
$ alias greet='echo "alias version"'
$ greet
alias version

$ unalias greet
$ greet
function version

$ unset -f greet
$ type greet
bash: type: greet: not found

## 3. PATH search: local script unreachable without PATH entry

$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin
(no $HOME entry)

$ export PATH="$PATH:$HOME"
$ greet() { echo "function version"; }
$ greet
function version

## 4. Hard links: same inode, shared data

$ echo "original content" > /tmp/original.txt
$ ln /tmp/original.txt /tmp/linked.txt
$ ls -li /tmp/original.txt /tmp/linked.txt
1704018 -rw-rw-r-- 2 ubuntulab ubuntulab 17 Sep 17 01:35 /tmp/linked.txt
1704018 -rw-rw-r-- 2 ubuntulab ubuntulab 17 Sep 17 01:35 /tmp/original.txt

$ rm /tmp/original.txt
$ ls -li /tmp/linked.txt
1704018 -rw-rw-r-- 1 ubuntulab ubuntulab 17 Sep 17 01:35 /tmp/linked.txt
$ cat /tmp/linked.txt
original content

## 5. Symlinks: separate inode, path-string content, dangling on target deletion

$ echo "changed target" > /tmp/target.txt
$ ln -s /tmp/target.txt /tmp/symlink.txt
$ ls -li /tmp/target.txt /tmp/symlink.txt
1704022 lrwxrwxrwx 1 ubuntulab ubuntulab 15 Sep 17 02:27 /tmp/symlink.txt -> /tmp/target.txt
1704021 -rw-rw-r-- 1 ubuntulab ubuntulab 15 Sep 17 02:54 /tmp/target.txt

$ rm /tmp/target.txt
$ ls -li /tmp/symlink.txt
1704022 lrwxrwxrwx 1 ubuntulab ubuntulab 15 Sep 17 02:27 /tmp/symlink.txt -> /tmp/target.txt
$ cat /tmp/symlink.txt
cat: /tmp/symlink.txt: No such file or directory

## 6. find | xargs whitespace bug

$ touch "/tmp/my file.log"
$ find /tmp -name '*.log' | xargs rm
$ ls /tmp/my*.log
'/tmp/my file.log'      ← survived, rm silently failed on split args

Fix:
$ find /tmp -name '*.log' -print0 | xargs -0 rm
$ ls /tmp/my*.log
ls: cannot access '/tmp/my*.log': No such file or directory   ← correctly removed

## 7. BREAK: PATH corruption

$ export PATH=""
$ ls
bash: ls: No such file or directory
$ echo "still alive"
still alive

Hypothesis 1 (rejected): stale hash cache serving old /usr/bin/ls path.
  $ type ls
  ls is aliased to `ls --color=auto'
  $ hash
  hash: hash table empty          ← disproves hypothesis 1

Hypothesis 2 (confirmed): empty PATH component == search cwd only.
  $ printf '#!/bin/bash\necho "local ls ran"\n' > ./ls
  $ chmod +x ./ls
  bash: chmod: No such file or directory     ← chmod itself unreachable, external
  $ ls
  bash: ls: Permission denied                ← different error: file found in cwd, not executable

Fix:
$ export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
$ ls
Desktop  Documents  Downloads  ... ls ...   ← recovered
$ rm ./ls


