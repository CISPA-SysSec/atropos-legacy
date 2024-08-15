#define _GNU_SOURCE         /* See feature_test_macros(7) */
#include <stdio.h>
#include <sys/shm.h>

#include "nyx.h"

uint8_t* trace_buffer; // <-- coverage
kAFL_payload* payload_buffer;
host_config_t *host_config;
agent_config_t agent_config = {0};
int shm_id;

void capabilites_configuration(bool timeout_detection, bool agent_tracing, bool ijon_tracing) {
    static bool done = false;

    if(!done) {
        /* if you want to debug code running in Nyx, hprintf() is the way to go.
        *  Long story short -- it's just a guest-to-hypervisor printf. Hence the name
        * "hprintf"
        */
        hprintf("Agent test\n");

        /* Request information on available (host) capabilites (optional) */
        kAFL_hypercall(HYPERCALL_KAFL_GET_HOST_CONFIG, host_config);
        hprintf("[capablities] host_config->bitmap_size: 0x%" PRIx64 "\n",
                host_config->bitmap_size);
        hprintf("[capablities] host_config->ijon_bitmap_size: 0x%" PRIx64 "\n",
                host_config->ijon_bitmap_size);
        hprintf("[capablities] host_config->payload_buffer_size: 0x%" PRIx64 "x\n",
                host_config->payload_buffer_size);

        /* this is our "bitmap" that is later shared with the fuzzer (you can also
        * pass the pointer of the bitmap used by compile-time instrumentations in
        * your target) */
        // uint8_t *trace_buffer = mmap(NULL, MMAP_SIZE(host_config->bitmap_size), PROT_READ | 
        //                             PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1, 0);
        // memset(trace_buffer, 0,
        //         host_config->bitmap_size);  // makes sure that the bitmap buffer is already
        //                             // mapped into the guest's memory (alternatively
        //                             // you can use mlock) */

        // make the buffer available to other processes via shmat
        shm_id = shmget(IPC_PRIVATE, MMAP_SIZE(host_config->bitmap_size), IPC_CREAT | IPC_EXCL | 0600);
        if (shm_id < 0) hprintf("shmget() failed\n");
        trace_buffer = shmat(shm_id, NULL, 0);
        if (trace_buffer == (void *)-1) hprintf("shmat() failed\n");
        memset(trace_buffer, 0x0, host_config->bitmap_size);
        mlock(trace_buffer, host_config->bitmap_size);
        hprintf("nyx.c trace_buffer: %p\n", trace_buffer);

		// uint8_t* tmp_trace_buffer = shmat(shm_id, NULL, 0);
		// hprintf("tmp_trace_buffer: %p\n", tmp_trace_buffer);

        /* Submit agent configuration */
        agent_config.agent_magic = NYX_AGENT_MAGIC;
        agent_config.agent_version = NYX_AGENT_VERSION;
        agent_config.agent_timeout_detection =
            timeout_detection; /* timeout detection is implemented by the agent (currently not used)
                */
        agent_config.agent_tracing =
            agent_tracing; /* set this flag to propagade that instrumentation-based fuzzing is
                    availabe */
        agent_config.agent_ijon_tracing = ijon_tracing; /* set this flag to propagade that IJON
                                                extension is implmented agent-wise */
        agent_config.trace_buffer_vaddr =
            (uintptr_t)trace_buffer; /* trace "bitmap" pointer - required for
                                        instrumentation-only fuzzing */
        agent_config.ijon_trace_buffer_vaddr =
            (uintptr_t)NULL;                             /* "IJON" buffer pointer */
        agent_config.agent_non_reload_mode =
            1; /* non-reload mode is supported (usually because the agent implements a
                    fork-server; currently not used) */
        agent_config.coverage_bitmap_size = host_config->bitmap_size;
        kAFL_hypercall(HYPERCALL_KAFL_SET_AGENT_CONFIG, (uintptr_t)&agent_config);

        /* Tell hypervisor the virtual address of the payload (input) buffer (call
        * mlock to ensure that this buffer stays in the guest's memory)*/
        payload_buffer =
            mmap(NULL, host_config->payload_buffer_size, PROT_READ | PROT_WRITE,
                MAP_SHARED | MAP_ANONYMOUS, -1, 0);
        mlock(payload_buffer, (size_t)host_config->payload_buffer_size);
        memset(payload_buffer, 0, host_config->payload_buffer_size);
        kAFL_hypercall(HYPERCALL_KAFL_GET_PAYLOAD, (uintptr_t)payload_buffer);
        hprintf("[init] payload buffer is mapped at %p\n", payload_buffer);
    }
}

int executed_in_vm() {
	//return (access("/tmp/on_host", F_OK ) != 0); 
	return (getenv("IN_NYX") != NULL);
}

void nyx_init() {
    hprintf("PHP-Agent start\n");

    host_config = malloc(sizeof(host_config_t));
    capabilites_configuration(false, true, false);
}

void* nyx_get_trace_buffer() {
    return trace_buffer;
}

char* nyx_get_payload() {
    return payload_buffer->data;
}

uint32_t nyx_get_payload_len() {
    return payload_buffer->size - sizeof(payload_buffer->size);
}

int nyx_is_payload_null() {
    return (payload_buffer == NULL);
}

void nyx_create_snapshot() {
    kAFL_hypercall(HYPERCALL_KAFL_USER_FAST_ACQUIRE, 0); // root snapshot <--
    ((uint8_t*)trace_buffer)[0] = 0x1;
}

void nyx_exit() {
    // for(int i = 0; i < 0xffff; i++){ 
    //     if(((uint8_t*)trace_buffer)[i] != 0x00)
    //         hprintf("%04x: %02x", i, ((uint8_t*)trace_buffer)[i]);
    // }
	kAFL_hypercall(HYPERCALL_KAFL_RELEASE, 0);
}

int nyx_get_shm_id() {
    return shm_id;
}

int nyx_get_bitmap_size() {
    return host_config->bitmap_size;
}

void nyx_set_bitmap(uint32_t key, uint32_t offset) {
    ((uint8_t*)trace_buffer)[(key + (offset & 0x7)) & (host_config->bitmap_size-1)] = 0x1;
}

void nyx_report_crash(char* m) {
    static uint8_t msg[0x1000] __attribute__((aligned(0x1000)));
    strncpy(msg, m, 0x1000-1);
    kAFL_hypercall(HYPERCALL_KAFL_PANIC_EXTENDED, (void*)m);
}

void nyx_html_dump(char* buffer, uint32_t len, uint32_t pinned_core) {
    static bool html_dump_init = false;
    static kafl_dump_file_t html_dump_obj = {0};

	if(len == 0)
		return;

    if (!html_dump_init){
		char *filename_with_core;
		asprintf(&filename_with_core, "html_%d", pinned_core);
		if(!filename_with_core)
			return;
        html_dump_obj.file_name_str_ptr = (uintptr_t)filename_with_core;
        html_dump_obj.append = 0;
        html_dump_obj.bytes = 0;
        kAFL_hypercall(HYPERCALL_KAFL_DUMP_FILE, (uintptr_t) (&html_dump_obj));
        html_dump_init=true;
    }

    html_dump_obj.append = 1;
    html_dump_obj.bytes = len;
    html_dump_obj.data_ptr = (uintptr_t)buffer;
    kAFL_hypercall(HYPERCALL_KAFL_DUMP_FILE, (uintptr_t) (&html_dump_obj));
}

void nyx_hprintf(char* buf) {
    hprintf("%s", buf);
}