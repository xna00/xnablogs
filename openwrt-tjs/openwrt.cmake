# the name of the target operating system
set(CMAKE_SYSTEM_NAME Linux)

# which C and C++ compiler to use
set(CMAKE_C_COMPILER /root/openwrt-sdk-mediatek-filogic_gcc-14.2.0_musl.Linux-x86_64/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.2.0_musl/bin/aarch64-openwrt-linux-gcc)
set(CMAKE_CXX_COMPILER /root/openwrt-sdk-mediatek-filogic_gcc-14.2.0_musl.Linux-x86_64/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.2.0_musl/bin/aarch64-openwrt-linux-g++)

# location of the target environment
set(CMAKE_FIND_ROOT_PATH
       	"/root/openwrt-sdk-mediatek-filogic_gcc-14.2.0_musl.Linux-x86_64/staging_dir/target-aarch64_cortex-a53_musl/usr"
	"/root/openwrt-sdk-mediatek-filogic_gcc-14.2.0_musl.Linux-x86_64/staging_dir/toolchain-aarch64_cortex-a53_gcc-14.2.0_musl"
)

# adjust the default behavior of the FIND_XXX() commands:
# search for headers and libraries in the target environment,
# search for programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)