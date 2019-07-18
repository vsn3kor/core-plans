pkg_name=dotnet-asp-core
pkg_origin=core
pkg_version=2.2.6
pkg_license=('MIT')
pkg_upstream_url=https://docs.microsoft.com/en-us/aspnet/core
pkg_description="ASP.NET Core is a cross-platform, high-performance, open-source framework for building modern, cloud-based, Internet-connected applications."
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_source="https://download.visualstudio.microsoft.com/download/pr/5d59077f-07f3-4997-b514-d88bce8cdcbf/3729ac370c4b96720829e098bee7ee5e/aspnetcore-runtime-${pkg_version}-linux-x64.tar.gz"
pkg_shasum=1e5687ab1b52fc342211607af829d847b96976737f187394b468d27b9f3ae7af
pkg_filename="aspnetcore-runtime-${pkg_version}-linux-x64.tar.gz"
pkg_deps=(
  core/curl
  core/gcc-libs
  core/glibc
  core/icu52
  core/krb5
  core/libunwind
  core/lttng-ust
  core/openssl
  core/util-linux
  core/zlib
)
pkg_build_deps=(
  core/patchelf
)
pkg_bin_dirs=(bin)

do_unpack() {
  # Extract into $pkg_dirname instead of straight into $HAB_CACHE_SRC_PATH.
  mkdir -p "${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
  tar xf "${HAB_CACHE_SRC_PATH}/${pkg_filename}" \
    -C "${HAB_CACHE_SRC_PATH}/${pkg_dirname}" \
    --no-same-owner
}

do_prepare() {
  find . -type f -name 'dotnet' \
    -exec patchelf --interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" --set-rpath "${LD_RUN_PATH}" {} \;
  find . -type f -name '*.so*' \
    -exec patchelf --set-rpath "${LD_RUN_PATH}" {} \;
}

do_build() {
  return 0
}

do_install() {
  cp -a . "${pkg_prefix}/bin"
  chmod o+r -R "${pkg_prefix}/bin"
  # Move text files out of bin directory
  mv "${pkg_prefix}/bin/LICENSE.txt" "${pkg_prefix}/LICENSE.txt"
  mv "${pkg_prefix}/bin/ThirdPartyNotices.txt" "${pkg_prefix}/ThirdPartyNotices.txt"
}

do_strip() {
  return 0
}
