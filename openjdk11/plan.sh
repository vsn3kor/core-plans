pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_name=openjdk11
pkg_version="11.0.1+13"
pkg_source=https://hg.openjdk.java.net/jdk-updates/jdk11u/archive/jdk-${pkg_version}.tar.bz2
pkg_shasum=c6a50a814008d80f489bbb7e761e417f24db4461b6a6df5e210f484b738b1ff6
pkg_filename=jdk-${pkg_version}.tar.bz2
pkg_dirname="jdk11u-jdk-${pkg_version}"
pkg_license=("GPL-2.0")
pkg_description=('Oracle Java Runtime Environment. This package is made available to you to allow you to run your applications as provided in and subject to the terms of the Oracle Binary Code License Agreement for the Java SE Platform Products and JavaFX, found at http://www.oracle.com/technetwork/java/javase/terms/license/index.html')
pkg_upstream_url=https://openjdk.java.net/
pkg_build_deps=(
  core/bash
  core/autoconf
  core/automake
  core/cacerts
  core/diffutils
  core/gcc
  core/giflib
  core/lcms2
  core/libffi
  core/libpng
  core/libtool
  core/make
  core/m4
  core/openjpeg
  core/patchelf
  core/pkg-config
  core/which
  core/zip
)
pkg_deps=(
  core/glibc
  core/gcc-libs
  core/xlib
  core/libxi
  core/libxext
  core/libxrender
  core/libxtst
  core/zlib
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

boot_jdk_version="11.0.1"
boot_jdk_source="https://download.java.net/java/GA/jdk11/13/GPL/openjdk-${boot_jdk_version}-x64_bin.tar.gz"
boot_jdk_filename="openjdk-${boot_jdk_version}_linux-x64_bin.tar.gz"
boot_jdk_shasum="7a6bb980b9c91c478421f865087ad2d69086a0583aeeb9e69204785e8e97dcfd"

do_before() {
  boot_jdk_dirname="jdk-${boot_jdk_version}"
  boot_jdk_cache_path="$HAB_CACHE_SRC_PATH/${boot_jdk_dirname}"
}

do_download() {
  do_default_download
  download_file $boot_jdk_source $boot_jdk_filename $boot_jdk_shasum
}

do_verify() {
  do_default_verify
  verify_file $boot_jdk_filename $boot_jdk_shasum
}

do_unpack() {
  do_default_unpack
  unpack_file $boot_jdk_filename
}

do_setup_environment() {
  set_buildtime_env AUTOCONF "$(pkg_path_for autoconf)/bin/autoconf"
  #push_runtime_env JAVA_HOME "${pkg_prefix}"
}

do_prepare() {
  build_line "Preparing boot JDK for use"
  export TMP_LD_RUN_PATH="${LD_RUN_PATH}:${boot_jdk_cache_path}/lib/jli:${boot_jdk_cache_path}/lib/server:${boot_jdk_cache_path}/lib"

  find "${boot_jdk_cache_path}"/bin -type f -executable \
    -exec sh -c 'file -i "$1" | grep -q "x-executable; charset=binary"' _ {} \; \
    -exec patchelf --interpreter "$(pkg_path_for glibc)/lib/ld-linux-x86-64.so.2" --set-rpath "${TMP_LD_RUN_PATH}" {} \;

  find "${boot_jdk_cache_path}/lib" -type f -name "*.so" \
    -exec patchelf --set-rpath "${TMP_LD_RUN_PATH}" {} \;

  mkdir -p ${pkg_prefix}

  # TODO:  need to create a "combined" X11 libs and includes folder that ties together all the X packages
  #        because Java's configure only understands a single path for X (--with-x, --x-includes, --x-libraries)
}

do_build() {
  bash configure \
    --prefix=${pkg_prefix} \
    --exec-prefix=${pkg_prefix} \
    --with-cacerts-file="$(pkg_path_for cacerts)/ssl/certs/cacert.pem" \
    --with-boot-jdk="${boot_jdk_cache_path}" \
    --enable-headless-only || attach
    #--with-libffi
    #--with-zlib
    
  attach
}

#  bash configure --prefix=${pkg_prefix} --exec-prefix=${pkg_prefix} --with-cacerts-file="$(pkg_path_for cacerts)/ssl/certs/cacert.pem" --with-boot-jdk="${boot_jdk_cache_path}" --enable-headless-only

do_clean() {
  do_default_clean
  rm -rf "$boot_jdk_cache_path"
}
