# N.B. It may be a surprise that the derivation-specific variables are exported,
# since this is just sourced by the wrapped binaries---the end consumers. This
# is because one wrapper binary may invoke another (e.g. cc invoking ld). In
# that case, it is cheaper/better to not repeat this step and let the forked
# wrapped binary just inherit the work of the forker's wrapper script.

var_templates_list=(
    NIX_CFLAGS_COMPILE
    NIX_CFLAGS_COMPILE_BEFORE
    NIX_CFLAGS_LINK
    NIX_CXXSTDLIB_COMPILE
    NIX_CXXSTDLIB_LINK
    NIX_GNATFLAGS_COMPILE
)
var_templates_bool=(
    NIX_ENFORCE_NO_NATIVE
)

accumulateRoles

# We need to mangle names for hygiene, but also take parameters/overrides
# from the environment.
for var in "${var_templates_list[@]}"; do
    mangleVarList "$var" ${role_suffixes[@]+"${role_suffixes[@]}"}
done
for var in "${var_templates_bool[@]}"; do
    mangleVarBool "$var" ${role_suffixes[@]+"${role_suffixes[@]}"}
done

# `-B/nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/bin' forces cc to use ld-wrapper.sh when calling ld.
NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu="-B/nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/bin/ $NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu"

# Export and assign separately in order that a failing $(..) will fail
# the script.

# Currently bootstrap-tools does not split glibc, and gcc files into
# separate directories. As a workaround we want resulting cflags to be
# ordered as: crt1-cflags libc-cflags cc-cflags. Otherwise we mix crt/libc.so
# from different libc as seen in
#   https://github.com/NixOS/nixpkgs/issues/158042
#
# Note that below has reverse ordering as we prepend flags one-by-one.
# Once bootstrap-tools is split into different directories we can stop
# relying on flag ordering below.

if [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/cc-cflags ]; then
    NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu="$(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/cc-cflags) $NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu"
fi

if [[ "$cInclude" = 1 ]] && [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libc-cflags ]; then
    NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu="$(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libc-cflags) $NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu"
fi

if [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libc-crt1-cflags ]; then
    NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu="$(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libc-crt1-cflags) $NIX_CFLAGS_COMPILE_x86_64_unknown_linux_gnu"
fi

if [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libcxx-cxxflags ]; then
    NIX_CXXSTDLIB_COMPILE_x86_64_unknown_linux_gnu+=" $(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libcxx-cxxflags)"
fi

if [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libcxx-ldflags ]; then
    NIX_CXXSTDLIB_LINK_x86_64_unknown_linux_gnu+=" $(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/libcxx-ldflags)"
fi

if [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/gnat-cflags ]; then
    NIX_GNATFLAGS_COMPILE_x86_64_unknown_linux_gnu="$(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/gnat-cflags) $NIX_GNATFLAGS_COMPILE_x86_64_unknown_linux_gnu"
fi

if [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/cc-ldflags ]; then
    NIX_LDFLAGS_x86_64_unknown_linux_gnu+=" $(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/cc-ldflags)"
fi

if [ -e /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/cc-cflags-before ]; then
    NIX_CFLAGS_COMPILE_BEFORE_x86_64_unknown_linux_gnu="$(< /nix/store/yd5fiz2r8dlj739w4b3faay5x9aq4147-bootstrap-stage1-gcc-wrapper-/nix-support/cc-cflags-before) $NIX_CFLAGS_COMPILE_BEFORE_x86_64_unknown_linux_gnu"
fi

# Only add darwin min version flag if a default darwin min version is set,
# which is a signal that we're targetting darwin.
if [ "" ]; then
    mangleVarSingle  ${role_suffixes[@]+"${role_suffixes[@]}"}

    NIX_CFLAGS_COMPILE_BEFORE_x86_64_unknown_linux_gnu="-m-version-min=${_x86_64_unknown_linux_gnu:-} $NIX_CFLAGS_COMPILE_BEFORE_x86_64_unknown_linux_gnu"
fi

# That way forked processes will not extend these environment variables again.
export NIX_CC_WRAPPER_FLAGS_SET_x86_64_unknown_linux_gnu=1
