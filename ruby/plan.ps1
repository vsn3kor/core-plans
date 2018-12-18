$pkg_name="ruby"
$pkg_origin="core"
$pkg_version="2.5.1"
$pkg_file_name=$pkg_name + ($pkg_version).Replace(".", "")
$pkg_description="A dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write."
$pkg_upstream_url="https://www.ruby-lang.org/en/"
$pkg_license=("Ruby")
$pkg_source="https://cache.ruby-lang.org/pub/${pkg_name}/${pkg_name}-${pkg_version}.zip"
$pkg_shasum="5d8e490896c8353aa574be56ca9aa52c250390e76e36cd23df450c0434ada4d4"
$pkg_deps=@(
    "core/openssl",
    "core/zlib"
)
$pkg_build_deps=@(
    "core/visual-cpp-build-tools-2015"
)
$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")
$pkg_include_dirs=@("include")

function Invoke-SetupEnvironment {
    . "$(Get-HabPackagePath visual-cpp-build-tools-2015)\setenv.ps1"
}

function Invoke-Build {
    cd "$pkg_name-$pkg_version"
    .\win32\configure.bat --target=x64-mswin64 --prefix="$pkg_prefix"

    nmake
    nmake test
    nmake install
    # $zlib_libdir = "$(Get-HabPackagePath zlib)\lib\zlibwapi.lib"
    # $zlib_includedir = "$(Get-HabPackagePath zlib)\include"

    # mkdir build
    # cd build
    # cmake -G "Visual Studio 14 2015 Win64" -T "v140" -DCMAKE_SYSTEM_VERSION="8.1" -DCMAKE_INSTALL_PREFIX=../../../../install -DZLIB_LIBRARY_RELEASE="${zlib_libdir}" -DZLIB_INCLUDE_DIR="${zlib_includedir}" ..
    # # We'll build the required parts here
    # msbuild /p:Configuration=Release /p:Platform=x64 "INSTALL.vcxproj"
    # if($LASTEXITCODE -ne 0) { Write-Error "msbuild failed!" }

    # .\extract_includes.bat
}

# function Invoke-Install {
#     Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\cmake\build\Release\protoc.exe" "$pkg_prefix\bin\" -Force
#     Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\cmake\build\Release\*.lib" "$pkg_prefix\lib\" -Force
#     Copy-Item "$HAB_CACHE_SRC_PATH\$pkg_name-$pkg_version\$pkg_name-$pkg_version\cmake\build\include\*" "$pkg_prefix\include\" -Force
# }
