Patch the stdenv of `nixpkgs` with oils-for-unix and try to build something with it.

Requirements:
- nix
- ysh
- a clone of [`nixpkgs`](https://github.com/NixOS/nixpkgs) somewhere.

# Usage

Prepare nixpkgs 
```
# A certain commit needs to be checked out in nixpkgs for it to work:
cd nixpkgs
git checkout a481a7c16caae63e6b1dc2e20bebac20392c86c1
cd THIS-REPO
ln -s PATH-TO-NIXPKGS ./nixpkgs
```

Now you can test a build of `bash`:
```
# replace the oils tarball with the newest one from https://www.oilshell.org/. a `.tar` or `.tar.gz` should both work.
./nix-patched-build.ysh http://travis-ci.oilshell.org/github-jobs/6567/cpp-tarball.wwz/_release/oils-for-unix.tar
```
