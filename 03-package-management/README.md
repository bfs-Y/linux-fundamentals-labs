# 03 - Package Management

Training on holds and version pins, on Ubuntu 24.04 (apt/dpkg) and Rocky 10 (dnf/rpm), with the same failure reproduced on both.

## The failure
`apt install nginx` or `dnf upgrade` fails and the package you asked for isn't the cause. A different package is held or locked, and the new version of yours needs an exact version of it (`Depends: x (= ...)`).

## What I did
- Baseline: file ownership, package databases, repo config, holds, on both distros.
- 03-B Ubuntu: nginx blocked by nginx-common held at an older version.
- 03-B Rocky: ghostscript blocked by a versionlock on ghostscript-tools-fonts.

## Layout
- `break/` scripts that create each failure (untested, run on a snapshot first)
- `fix/` the smallest change that clears it
- `drills/` cold-recall questions with answers from my own evidence
- `postmortem/` root cause and handover notes
- `test-log.md` dated command output

## Main findings
- `held broken packages` can appear with no hold at all. Run `apt-mark showhold` first.
- A hold or lock only breaks something when the held package is behind what another package requires.
- `apt install pkg=version` overrides a hold. dpkg and the status file record the hold but not who set it. The sudo journal does.
- Rocky's lock lives in a plain text file; Ubuntu's hold is a word in dpkg's status file.

## Open
- Break and fix scripts have not been run end to end.
- Anki deck for this module is kept outside the repo.
