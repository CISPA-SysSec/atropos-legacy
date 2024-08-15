#define NO_PT_NYX
#include "nyx.h"
#include <unistd.h>
#define _GNU_SOURCE         /* See feature_test_macros(7) */
#include <stdio.h>

int main(int argc, char** argv) {
    //char *msg;
    static uint8_t msg[0x1000] __attribute__((aligned(0x1000)));
    strncpy(msg, "bug oracle triggered: lfi\n", 0x1000-1);
    if(argc > 1) {
        sprintf(msg, "bug oracle triggered: lfi in %s\n", argv[1]);
    }
    printf("%s\n", msg);
    if( access("/tmp/bug_oracle_enabled", F_OK ) == 0 ) {
        //hprintf("bug oracle triggered: %s\n", msg);
        kAFL_hypercall(HYPERCALL_KAFL_PANIC_EXTENDED, (void*)msg);
    }
    return 0;
}
