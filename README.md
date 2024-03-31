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

## bind mount magic

To debug the stdenv it would be annoying to have to rebuild everytime we want to change e.g. the generated `setup` script. To make this process easier, there is the `bind_mount_path.ysh` file.
It takes any path (usually `/nix/store/xxx`), copies this path to `./patch` and bind-mounts it back to /nix/store.
E.g.:

```shell-session
osh-0.20.0$ ./bind_mount_path.ysh /nix/store/3gfzhrywf5hriin0nbrkbr9c3hzqls84-bootstrap-stage0-stdenv-linux/
Destination ./patch/3gfzhrywf5hriin0nbrkbr9c3hzqls84-bootstrap-stage0-stdenv-linux doesn't exist. Copying
[sudo] password for samuelh:
mount: /home/samuelh/git/private/nixpkgs_oils_patch/patch/3gfzhrywf5hriin0nbrkbr9c3hzqls84-bootstrap-stage0-stdenv-linux bound on /nix/store/3gfzhrywf5hriin0nbrkbr9c3hzqls84-bootstrap-stage0-stdenv-linux.
osh-0.20.0$ ls -lah /nix/store/3gfzhrywf5hriin0nbrkbr9c3hzqls84-bootstrap-stage0-stdenv-linux/
total 52K
drwxr-xr-x 1 example users    32 Jan  1  1970 .
drwxrwxr-t 1 root    nixbld 8.6M Mar 31 16:00 ..
drwxr-xr-x 1 example users     0 Jan  1  1970 nix-support
-rw-r--r-- 1 example users   51K Jan  1  1970 setup
osh-0.20.0$ mount | grep /nix/stor
/dev/mapper/crypted on /nix/store type btrfs (ro,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=257,subvol=/nix)
/dev/mapper/crypted on /nix/store/3gfzhrywf5hriin0nbrkbr9c3hzqls84-bootstrap-stage0-stdenv-linux type btrfs (rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=256,subvol=/home)
osh-0.20.0$
```

As you see the `setup` file looks to be writable and owned by the `example` user. But in reality this is the file under `./patch/3gfzhrywf5hriin0nbrkbr9c3hzqls84-bootstrap-stage0-stdenv-linux/setup`.
(I'm sorry I have btrfs and cryptsetup. Otherwise the mount output would be more instructive :).
