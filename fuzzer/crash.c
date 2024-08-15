#define NO_PT_NYX
#include "nyx.h"
#include <unistd.h>

int main(int argc, char** argv) {
    //char *msg;
    static uint8_t msg[0x1000] __attribute__((aligned(0x1000)));
    strncpy(msg, "bug oracle triggered: validated rce\n", 0x1000-1);
    if( access("/tmp/bug_oracle_enabled", F_OK ) == 0 ) {
        //hprintf("bug oracle triggered: %s\n", msg);
        //kAFL_hypercall(HYPERCALL_KAFL_PANIC_EXTENDED, (void*)msg);
		FILE *f = fopen("/tmp/bug_triggered", "a+");
		if(f) {
			fwrite(msg, 1, strlen(msg), f);
			fclose(f);
		}
    }
}
