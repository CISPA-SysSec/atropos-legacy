chmod +x hget
cp hget /tmp/
cd /tmp/
echo 0 > /proc/sys/kernel/randomize_va_space
echo 0 > /proc/sys/kernel/printk
./hget hcat hcat
./hget habort habort
chmod +x hcat
chmod +x habort
./hget ld_preload_fuzz.so ld_preload_fuzz.so
chmod +x ld_preload_fuzz.so
echo "Let's get our dependencies..." | ./hcat
./hget ld-linux-x86-64.so.2 ld-linux-x86-64.so.2
./hget libc.so.6 libc.so.6
echo "Let's get our target executable..." | ./hcat
./hget php-nim target_executable
chmod +x target_executable
LD_LIBRARY_PATH=/tmp/ LD_BIND_NOW=1 LD_PRELOAD=/tmp/ld_preload_fuzz.so ASAN_OPTIONS=detect_leaks=0:allocator_may_return_null=1:log_path=/tmp/data.log:abort_on_error=true NYX_AFL_PLUS_PLUS_MODE=ON NYX_FAST_EXIT_MODE=TRUE NYX_PT_RANGE_AUTO_CONF_A=ON NYX_PT_RANGE_AUTO_CONF_B=ON MALLOC_CHECK_=2 ./target_executable   > /dev/null 2> /dev/null
dmesg | grep segfault | ./hcat
./habort
