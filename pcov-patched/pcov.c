/*
  +----------------------------------------------------------------------+
  | Copyright (c) The PHP Group                                          |
  +----------------------------------------------------------------------+
  | This source file is subject to version 3.01 of the PHP license,      |
  | that is bundled with this package in the file LICENSE, and is        |
  | available through the world-wide-web at the following url:           |
  | http://www.php.net/license/3_01.txt                                  |
  | If you did not receive a copy of the PHP license and are unable to   |
  | obtain it through the world-wide-web, please send a note to          |
  | license@php.net so we can mail you a copy immediately.               |
  +----------------------------------------------------------------------+
  | Author: krakjoe                                                      |
  +----------------------------------------------------------------------+
*/

/* $Id$ */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#define NO_PT_NYX
#include "nyx.h"
#include "hashmap.h"
#include "murmur3.h"
#include <sys/shm.h>

#include "php.h"
#include "php_ini.h"
#include "ext/standard/info.h"

#include "zend_arena.h"
#if PHP_VERSION_ID < 80100
# include "zend_cfg.h"
# define PHP_PCOV_CFG ZEND_RT_CONSTANTS
#else
# include "Zend/Optimizer/zend_cfg.h"
# define PHP_PCOV_CFG 0
#endif
#include "zend_exceptions.h"
#include "zend_vm.h"
#include "zend_vm_opcodes.h"
#include "zend_compile.h"
#include "zend_vm_opcodes.h"
#include "zend_generators.h"

#include "php_pcov.h"

#define PCOV_FILTER_ALL     0
#define PCOV_FILTER_INCLUDE 1

#define PHP_PCOV_UNCOVERED   -1
#define PHP_PCOV_COVERED      1

#ifndef GC_ADDREF
#	define GC_ADDREF(g) ++GC_REFCOUNT(g)
#endif

#if PHP_VERSION_ID < 70300
#define php_pcre_pce_incref(c) (c)->refcount++
#define php_pcre_pce_decref(c) (c)->refcount--
#define GC_SET_REFCOUNT(ref, rc) (GC_REFCOUNT(ref) = (rc))
#endif

#define PHP_PCOV_API_ENABLED_GUARD() do { \
	if (!INI_BOOL("pcov.enabled")) { \
		return; \
	} \
} while (0);

static zval php_pcov_uncovered;
static zval php_pcov_covered;

extern void (*zend_string_equal_val_callback)(char* s1, int s1_len, char* s2, int s2_len);
void php_pcov_string_equal_val(char* s1, int s1_len, char* s2, int s2_len);
extern void (*zend_array_access_callback)(char* s1, int len);
void php_pcov_array_access(char* s1, int len);
extern void (*zend_bug_oracle_callback)(char* error_msg, char* type);
void php_pcov_bug_oracle(char* error_msg, char* type);
extern void (*zend_redqueen_callback)(char* s, int len, uint8_t type);
void php_pcov_redqueen(char* s, int len, uint8_t type);
extern void (*zend_positive_feedback_callback)(int id);
void php_pcov_positive_feedback(int id);
extern void (*zend_redqueen_preg_match_callback)(char* regexp, int regexp_len, char* cmp, int cmp_len);
void php_pcov_redqueen_preg_match(char* regexp, int regexp_len, char* cmp, int cmp_len);

void php_pcov_redqueen_unmatched(char *s1, int len1, char* s2, int len2);

void (*zend_execute_ex_function)(zend_execute_data *execute_data);
zend_op_array* (*zend_compile_file_function)(zend_file_handle *fh, int type) = NULL;

#define CURRENT_FILENAME_LENGTH (PATH_MAX+1)
#define CURRENT_BACKTRACE_LENGTH CURRENT_FILENAME_LENGTH
#define MAX_OPCODE_POS 100
#define MAX_FEEDBACK_PER_FILE_LINE 8
#define BITMAP_OFFSET_AND (MAX_FEEDBACK_PER_FILE_LINE-1)
#define MAX_BACKTRACE_DEPTH 3
char* current_filename = NULL;
char *current_relative_filename = NULL;
char *current_backtrace = NULL;
uint32_t current_lineno = 0;
uint32_t current_opcode_pos = 0;
uint32_t last_coverage_hash = 0;
bool redqueen_mode_enabled = false;
bool coverage_dump_enabled = false;
uint32_t execution_limit = 0;
uint32_t executed_opcodes = 0;
int pinned_core = 0;
unsigned int bitmap_size = 65536;
unsigned int bitmap_mask = 0xffff;
bool is_in_eval = false;
uint32_t filename_hash = 0;
uint32_t backtrace_hash = 0;

#define REDQUEEN_STRING 0
#define REDQUEEN_ARRAY_ACCESS 1
#define REDQUEEN_UNMATCHED_STRING 2
#define REDQUEEN_PREG_MATCH 3

ZEND_DECLARE_MODULE_GLOBALS(pcov)

PHP_INI_BEGIN()
	STD_PHP_INI_BOOLEAN(
		"pcov.enabled", "1",
		PHP_INI_SYSTEM, OnUpdateBool,
		ini.enabled, zend_pcov_globals, pcov_globals)
	STD_PHP_INI_ENTRY  (
		"pcov.directory", "",
		PHP_INI_SYSTEM | PHP_INI_PERDIR, OnUpdateString,
		ini.directory, zend_pcov_globals, pcov_globals)
	STD_PHP_INI_ENTRY(
		"pcov.initial.memory", "261344",
		PHP_INI_SYSTEM | PHP_INI_PERDIR, OnUpdateLong,
		ini.memory, zend_pcov_globals, pcov_globals)
	STD_PHP_INI_ENTRY(
		"pcov.initial.files", "10000",
		PHP_INI_SYSTEM | PHP_INI_PERDIR, OnUpdateLong,
		ini.files, zend_pcov_globals, pcov_globals)
PHP_INI_END()

static PHP_GINIT_FUNCTION(pcov)
{
#if defined(COMPILE_DL_PCOV) && defined(ZTS)
	ZEND_TSRMLS_CACHE_UPDATE();
#endif

	ZEND_SECURE_ZERO(pcov_globals, sizeof(zend_pcov_globals));
}

// static void dump_payload(void* buffer, size_t len, const char* filename) {
//     static kafl_dump_file_t file_obj = {0};

// 	file_obj.file_name_str_ptr = (uintptr_t)filename;
//     file_obj.append = 0;
//     file_obj.bytes = len;
//     file_obj.data_ptr = (uintptr_t)buffer;
//     kAFL_hypercall(HYPERCALL_KAFL_DUMP_FILE, (uintptr_t) (&file_obj));
// }

static inline zend_bool pcov_skip_internal_handler(zend_execute_data *skip) /* {{{ */
{
	return !(skip->func && ZEND_USER_CODE(skip->func->common.type))
			&& skip->prev_execute_data
			&& skip->prev_execute_data->func
			&& ZEND_USER_CODE(skip->prev_execute_data->func->common.type)
			&& skip->prev_execute_data->opline->opcode != ZEND_DO_FCALL
			&& skip->prev_execute_data->opline->opcode != ZEND_DO_ICALL
			&& skip->prev_execute_data->opline->opcode != ZEND_DO_UCALL
			&& skip->prev_execute_data->opline->opcode != ZEND_DO_FCALL_BY_NAME
			&& skip->prev_execute_data->opline->opcode != ZEND_INCLUDE_OR_EVAL;
}

uint32_t pcov_backtrace(int limit) /* {{{ */
{
	zend_execute_data *ptr, *skip, *call = NULL;
	uint32_t lineno, frameno = 0;
	zend_string *filename;
	uint32_t _hash = 0;

	if (!(ptr = EG(current_execute_data))) {
		return 0;
	}

	if (!ptr->func || !ZEND_USER_CODE(ptr->func->common.type)) {
		call = ptr;
		ptr = ptr->prev_execute_data;
	}

	if (ptr) {
		/* skip "new Exception()" */
		if (ptr->func && ZEND_USER_CODE(ptr->func->common.type) && (ptr->opline->opcode == ZEND_NEW)) {
			call = ptr;
			ptr = ptr->prev_execute_data;
		}
		if (!call) {
			call = ptr;
			ptr = ptr->prev_execute_data;
		}
	}

	while (ptr && (limit == 0 || frameno < limit)) {
		frameno++;

		ptr = zend_generator_check_placeholder_frame(ptr);

		skip = ptr;
		/* skip internal handler */
		if (pcov_skip_internal_handler(skip)) {
			skip = skip->prev_execute_data;
		}

		if (skip->func && ZEND_USER_CODE(skip->func->common.type)) {
			filename = skip->func->op_array.filename;
			if (skip->opline->opcode == ZEND_HANDLE_EXCEPTION) {
				if (EG(opline_before_exception)) {
					lineno = EG(opline_before_exception)->lineno;
				} else {
					lineno = skip->func->op_array.line_end;
				}
			} else {
				lineno = skip->opline->lineno;
			}
			//printf("1 backtrace: %.*s:%d\n", filename->len, filename->val, lineno);
			MurmurHash3_x86_32(filename->val, filename->len, _hash, &_hash);
			//printf("--\n");
			MurmurHash3_x86_32(&lineno, sizeof(uint32_t), _hash, &_hash);

			/* try to fetch args only if an FCALL was just made - elsewise we're in the middle of a function
			 * and debug_baktrace() might have been called by the error_handler. in this case we don't
			 * want to pop anything of the argument-stack */
		} else {
			zend_execute_data *prev_call = skip;
			zend_execute_data *prev = skip->prev_execute_data;

			while (prev) {
				if (prev_call &&
					prev_call->func &&
					!ZEND_USER_CODE(prev_call->func->common.type) &&
					!(prev_call->func->common.fn_flags & ZEND_ACC_CALL_VIA_TRAMPOLINE)) {
					break;
				}
				if (prev->func && ZEND_USER_CODE(prev->func->common.type)) {
					//printf("2 backtrace: %.*s:%d\n", prev->func->op_array.filename->len, prev->func->op_array.filename->val, prev->opline->lineno);
					MurmurHash3_x86_32(prev->func->op_array.filename->val, prev->func->op_array.filename->len, _hash, &_hash);
					//printf("--\n");
					MurmurHash3_x86_32(&prev->opline->lineno, sizeof(uint32_t), _hash, &_hash);
					break;
				}
				prev_call = prev;
				prev = prev->prev_execute_data;
			}
			filename = NULL;
		}

		call = skip;
		ptr = skip->prev_execute_data;
	}
	return _hash;
}

void update_backtrace_hash() {
	backtrace_hash = pcov_backtrace(MAX_BACKTRACE_DEPTH);
	if(backtrace_hash == 0)
		backtrace_hash = filename_hash;
}

void enable_custom_feedback_functions() {
	//printf("enable_custom_feedback_functions\n");
	zend_redqueen_preg_match_callback = php_pcov_redqueen_preg_match;
	zend_redqueen_callback			  = php_pcov_redqueen;
	zend_array_access_callback 		  = php_pcov_array_access;
	zend_bug_oracle_callback          = php_pcov_bug_oracle;
	zend_positive_feedback_callback   = php_pcov_positive_feedback;
	zend_string_equal_val_callback    = php_pcov_string_equal_val;
}

void disable_custom_feedback_functions() {
	//printf("disable_custom_feedback_functions\n");
	zend_array_access_callback 		  = NULL;
	zend_bug_oracle_callback          = NULL;
	zend_redqueen_callback			  = NULL;
	zend_positive_feedback_callback   = NULL;
	zend_redqueen_preg_match_callback = NULL;
	zend_string_equal_val_callback    = NULL;
}

void reset_cov_context() {
	memset(current_filename, 0x00, CURRENT_FILENAME_LENGTH);
	memset(current_relative_filename, 0x00, CURRENT_FILENAME_LENGTH);
	current_lineno = 0;
	current_opcode_pos = 0;
	last_coverage_hash = 0;
	filename_hash = 0;
	backtrace_hash = 0;
}

#define test_feedback_conditions ((!is_in_eval) && (current_lineno > 0))

/*
bool test_feedback_conditions() {
	if(trace_buffer == NULL || is_in_eval)
		return false;
	return true;
}*/

/*
bool test_feedback_conditions() {
	return (trace_buffer != NULL && \
			current_filename != NULL && \
	        !is_in_eval && \
			strlen(current_filename) > 0 && \
			current_lineno > 0);
}*/

inline uint32_t read_from_trace_buffer(uint32_t index) {
	if(trace_buffer != NULL) {
		return ((uint8_t*)trace_buffer)[index];
	} else {
		return 0;
	}
}

inline void write_to_trace_buffer(uint32_t index) {
	if(trace_buffer != NULL) {
		((uint8_t*)trace_buffer)[index] = 1;
	} else {
		//printf("trace_buffer[%x] = 1\n", index);
	}
}

bool is_printable(char *s, int len) {
	for(int i = 0; i < len; i++) {
		if(!isprint(s[i]))
			return false;
	}
	return true;
}

static void _dump_payload(void* buffer, size_t len, const char* filename) {
    static bool init = false;
    static kafl_dump_file_t file_obj = {0};
	
    //printf("%s -> ptr: %p size: %lx - %s\n", __func__, buffer, len, filename);
	if(len == 0) {
		return;
	}

	// // only send this if it wasn't sent already
	// if(hashmap_get(&PCG(rq_map), buffer, len) != NULL) {
	// 	return;
	// }

	// // remember that we've sent this already
	// int set = 1;
	// if (hashmap_put(&PCG(rq_map), buffer, len, &set) != 0) {
	// 	return;
	// }

    if (!init) {
		char *filename_with_core;
		asprintf(&filename_with_core, "%s_%d", filename, pinned_core);
		//hprintf("filename_with_core: %s\n", filename_with_core);
		if(!filename_with_core)
			return;
        file_obj.file_name_str_ptr = (uintptr_t)filename_with_core;
        file_obj.append = 0;
        file_obj.bytes = 0;
        kAFL_hypercall(HYPERCALL_KAFL_DUMP_FILE, (uintptr_t) (&file_obj));
        init=true;
    }

    file_obj.append = 1;
    file_obj.bytes = len;
    file_obj.data_ptr = (uintptr_t)buffer;
    kAFL_hypercall(HYPERCALL_KAFL_DUMP_FILE, (uintptr_t) (&file_obj));
}

static void _cov_dump_payload(void* buffer, size_t len, const char* filename) {
    static bool cov_init = false;
    static kafl_dump_file_t cov_file_obj = {0};

    //printf("%s -> ptr: %p size: %lx - %s\n", __func__, buffer, len, filename);
	if(len == 0)
		return;

	// only send this if it wasn't sent already 
	// (avoid too many coverage information on lines that we've already seen before)
	// comment this out if you need a detailed tracing with ALL lines ever visited
	// if(hashmap_get(&PCG(cov_map), buffer, len) != NULL) {
	// 	return;
	// }

	// // remember that we've sent this already
	// int set = 1;
	// if (hashmap_put(&PCG(cov_map), buffer, len, &set) != 0) {
	// 	return;
	// }

    if (!cov_init){
		char *filename_with_core;
		asprintf(&filename_with_core, "%s_%d", filename, pinned_core);
		if(!filename_with_core)
			return;
		//hprintf("filename_with_core: %s\n", filename_with_core);
        cov_file_obj.file_name_str_ptr = (uintptr_t)filename_with_core;
        cov_file_obj.append = 0;
        cov_file_obj.bytes = 0;
        kAFL_hypercall(HYPERCALL_KAFL_DUMP_FILE, (uintptr_t) (&cov_file_obj));
        cov_init=true;
    }

    cov_file_obj.append = 1;
    cov_file_obj.bytes = len;
    cov_file_obj.data_ptr = (uintptr_t)buffer;
    kAFL_hypercall(HYPERCALL_KAFL_DUMP_FILE, (uintptr_t) (&cov_file_obj));
}

void dump_redqueen_payload(void* buffer, size_t len, uint8_t type) {
	char buf[1024];
	// [type][len]
	if(len > 1000)
		return;
	buf[0] = type;
	*(uint16_t*)(buf+1) = len;
	memcpy(buf+sizeof(uint8_t)+sizeof(uint16_t), buffer, len);
	_dump_payload(buf, sizeof(uint8_t)+sizeof(uint16_t)+len, "strings");
}

void dump_coverage(char* buffer) {
	if(coverage_dump_enabled)
		_cov_dump_payload(buffer, strlen(buffer), "coverage");
}

static zend_always_inline zend_bool php_pcov_wants(zend_string *filename) { /* {{{ */
	if (!PCG(directory)) {
		return 1;
	}

	if (ZSTR_LEN(filename) < ZSTR_LEN(PCG(directory))) {
		return 0;
	}

	if (zend_hash_exists(&PCG(wants), filename)) {
		return 1;
	}

	if (strncmp(
		ZSTR_VAL(filename),
		ZSTR_VAL(PCG(directory)),
		ZSTR_LEN(PCG(directory))) == SUCCESS) {

		zend_hash_add_empty_element(&PCG(wants), filename);
		return 1;
	}

	return 0;
} /* }}} */

static zend_always_inline zend_bool php_pcov_ignored_opcode(zend_uchar opcode) { /* {{{ */
	return
	    opcode == ZEND_NOP ||
	    opcode == ZEND_OP_DATA ||
	    opcode == ZEND_FE_FREE ||
	    opcode == ZEND_FREE ||
	    opcode == ZEND_ASSERT_CHECK ||
	    opcode == ZEND_VERIFY_RETURN_TYPE ||
	    opcode == ZEND_RECV ||
	    opcode == ZEND_RECV_INIT ||
	    opcode == ZEND_RECV_VARIADIC ||
	    opcode == ZEND_SEND_VAL ||
	    opcode == ZEND_SEND_VAR_EX ||
	    opcode == ZEND_SEND_REF ||
	    opcode == ZEND_SEND_UNPACK ||
	    opcode == ZEND_DECLARE_CONST ||
	    opcode == ZEND_DECLARE_CLASS ||
#ifdef ZEND_DECLARE_INHERITED_CLASS
	    opcode == ZEND_DECLARE_INHERITED_CLASS ||
	    opcode == ZEND_DECLARE_INHERITED_CLASS_DELAYED ||
	    opcode == ZEND_DECLARE_ANON_INHERITED_CLASS ||
#else
	    opcode == ZEND_DECLARE_CLASS_DELAYED ||
#endif
	    opcode == ZEND_DECLARE_FUNCTION ||
	    opcode == ZEND_DECLARE_ANON_CLASS ||
	    opcode == ZEND_FAST_RET ||
	    opcode == ZEND_FAST_CALL ||
	    opcode == ZEND_TICKS ||
	    opcode == ZEND_EXT_STMT ||
	    opcode == ZEND_EXT_FCALL_BEGIN ||
	    opcode == ZEND_EXT_FCALL_END ||
	    opcode == ZEND_EXT_NOP ||
#if PHP_VERSION_ID < 70400
	    opcode == ZEND_VERIFY_ABSTRACT_CLASS ||
	    opcode == ZEND_ADD_TRAIT ||
	    opcode == ZEND_BIND_TRAITS ||
#endif
	    opcode == ZEND_BIND_GLOBAL
	;
} /* }}} */

static zend_always_inline zend_string* php_pcov_interned_string(zend_string *string) { /* {{{ */
	if (ZSTR_IS_INTERNED(string)) {
		return string;
	}

	return zend_new_interned_string(zend_string_copy(string));
} /* }}} */

static zend_always_inline php_coverage_t* php_pcov_create(zend_execute_data *execute_data) { /* {{{ */
	php_coverage_t *create = (php_coverage_t*) zend_arena_alloc(&PCG(mem), sizeof(php_coverage_t));

	create->file     = php_pcov_interned_string(EX(func)->op_array.filename);
	create->line     = EX(opline)->lineno;
	create->next     = NULL;

	zend_hash_add_empty_element(&PCG(waiting), create->file);

	return create;
} /* }}} */

static zend_always_inline int php_pcov_has(zend_string *filename, uint32_t lineno) { /* {{{ */
	HashTable *table = zend_hash_find_ptr(&PCG(covered), filename);

	if (UNEXPECTED(!table)) {
		HashTable covering;

		zend_hash_init(&covering, 64, NULL, NULL, 0);

		table = zend_hash_add_mem(
			&PCG(covered), filename, &covering, sizeof(HashTable));

 		zend_hash_index_add_empty_element(table, lineno);
		return 0;
	}

	if (EXPECTED(zend_hash_index_exists(table, lineno))) {
		return 1;
	}

	zend_hash_index_add_empty_element(table, lineno);
	return 0;
} /* }}} */

uint32_t murmur_hash(const char *format, ...)
{
    va_list args;
    int count;

    va_start(args, format);

    __uint128_t output = 0;

    count = 0;
    while (*format != '\0') {
        switch (*format++) {
            case 's': ;
                char *str_k = va_arg(args, char *);
                //fprintf(stdout, "arg[%d]: %s\n", count, str_k);
                MurmurHash3_x64_128(str_k, strlen(str_k), (uint32_t)output, &output);
                break;
            case 'd': ;
                uint32_t i_k = va_arg(args, uint32_t);
                //fprintf(stdout, "arg[%d]: %u\n", count, i_k);
                MurmurHash3_x64_128(&i_k, sizeof(uint32_t), (uint32_t)output, &output);
                break;
        }
        count += 1;
    }
    va_end(args);
    return (uint32_t)output;
}

static uint32_t short_hash(int num,...) {
	static uint32_t hash_table[0x1000];
	va_list valist;
	uint32_t hash = 0;
	int i;

	// initialize hash_table for fast access to low values
	if(!*hash_table) {
		for(uint32_t i = 0; i < 0x1000; ++i)
			MurmurHash3_x86_32(&i, sizeof(uint32_t), 0, &hash_table[i]);
	}

	/* initialize valist for num number of arguments */
	va_start(valist, num);

	/* access all the arguments assigned to valist */
	for (i = 0; i < num; i++) {
		uint32_t v = va_arg(valist, uint32_t);
		if(v < 0x1000)
			v = hash_table[v];
		hash ^= v;
		hash >>= 1;
	}

	/* clean memory reserved for valist */
	va_end(valist);

	return hash;
}

static zend_always_inline int php_pcov_trace(zend_execute_data *execute_data) { /* {{{ */
    if (PCG(enabled)) {
		php_coverage_t *coverage = php_pcov_create(execute_data);

		//hprintf("%s %d %d\n", ZSTR_VAL(coverage->file), coverage->line, executed_opcodes);
		/*if(strcmp(PG(last_error_file), current_filename) == 0 && PG(last_error_lineno) == current_lineno) {
			// error happened on last line
		} else {
			// no error happened on last line, give feedback
			php_pcov_positive_feedback(0x7f); // md5("no_error")[0]
		}*/

		// update the file that we are currently running
		char abspath[PATH_MAX+1];
		// did the executed filename change?
		// (realpath is super slow for some reason, so this is a hack to reduce its usage)
		if(strcmp(current_relative_filename, ZSTR_VAL(coverage->file)) != 0) {
			strncpy(current_relative_filename, ZSTR_VAL(coverage->file), CURRENT_FILENAME_LENGTH-1);
			if(realpath(ZSTR_VAL(coverage->file), abspath) != NULL && access(abspath, F_OK) == 0) {
				if(strcmp(abspath, current_filename) != 0) {
					// get absolute file path
					strncpy(current_filename, abspath, CURRENT_FILENAME_LENGTH-1);
					is_in_eval = (strstr(current_filename, "eval()'d") != NULL);
					MurmurHash3_x86_32(current_filename, strlen(current_filename), 0, &filename_hash);
					current_lineno = coverage->line;
					current_opcode_pos = 0;
					last_coverage_hash = 0;
					update_backtrace_hash();
				}
			} else {
				// something is wrong with the file, reset all current information
				reset_cov_context();
				goto skip;
			}
		}
		if(current_lineno != coverage->line) {
			current_opcode_pos = 0;
			update_backtrace_hash();
		} 
		// update opcode pos but make sure we don't generate too many feedbacks for this
		current_opcode_pos = MIN(MAX_OPCODE_POS, current_opcode_pos + 1);
		current_lineno = coverage->line;
		//printf("cov %s:%d:%d\n", current_filename, current_lineno, current_opcode_pos);

		// ignore eval'd code, don't produce feedback (creates infinite feedback issues when RCE is possible)
 		if (!php_pcov_ignored_opcode(EX(opline)->opcode) || coverage_dump_enabled) {
			if(test_feedback_conditions) {
				uint32_t hash = short_hash(3, backtrace_hash, current_lineno, current_opcode_pos);
				// set edge in bitmap
				uint32_t edge_id = ((hash >> 1) ^ last_coverage_hash);
				write_to_trace_buffer(edge_id & bitmap_mask);
				//hprintf("written to %p[%x]\n", (uint8_t*)trace_buffer, edge_id & bitmap_mask);
				last_coverage_hash = hash;

				if(coverage_dump_enabled) {
					char *key_s;
					if(key_s) {
						asprintf(&key_s, "cov:%s:%04d:%d\n", current_filename, current_lineno, current_opcode_pos);
						dump_coverage(key_s);
						free(key_s);
					}
				}
			} else {
				reset_cov_context();
				goto skip;
			}
		}

skip:
		if (!PCG(start)) {
			PCG(start) = coverage;
		} else {
			*(PCG(next)) = coverage;
		}

		PCG(next) = &coverage->next;
	}

	return zend_vm_call_opcode_handler(execute_data);
} /* }}} */

// https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#C
#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))

unsigned int levenshtein(char *s1, char *s2) {
    unsigned int s1len, s2len, x, y, lastdiag, olddiag;
    s1len = strlen(s1);
    s2len = strlen(s2);
    unsigned int column[s1len + 1];
	memset(column, 0x00, sizeof(unsigned int) * (s1len+1));
    for (y = 1; y <= s1len; y++)
        column[y] = y;
    for (x = 1; x <= s2len; x++) {
        column[0] = x;
        for (y = 1, lastdiag = x - 1; y <= s1len; y++) {
            olddiag = column[y];
            column[y] = MIN3(column[y] + 1, column[y - 1] + 1, lastdiag + (s1[y-1] == s2[x - 1] ? 0 : 1));
            lastdiag = olddiag;
        }
    }
    return column[s1len];
}

void php_pcov_string_equal_val(char* s1, int s1_len, char* s2, int s2_len) { /* {{{ */
	php_pcov_redqueen(s1, s1_len, REDQUEEN_STRING);
	php_pcov_redqueen(s2, s2_len, REDQUEEN_STRING);
	// just in case we don't get an array access feedback, an input that is not set will be an empty string
	// so checking if both are greater than 0 might work like an array access feedback
	if(s1_len > 0 && s2_len > 0)
		php_pcov_positive_feedback(0xee); 
	// if strings are equal, give feedback
	if((s1_len == s2_len) && (memcmp(s1, s2, s1_len) == 0)) {
		//perfect match
		uint32_t s1_hash = murmur_hash("s", s1);
		// don't create too many feedback bits, limit it per file:line:opcode 
		// avoids issues where ($_GET['a'] == $_GET['a']) or similar
		uint32_t hash = short_hash(5, 0x1111, backtrace_hash, current_lineno, current_opcode_pos, (s1_hash & BITMAP_OFFSET_AND));
		int previously = read_from_trace_buffer(hash & bitmap_mask);
		if(test_feedback_conditions)
			write_to_trace_buffer(hash & bitmap_mask);
		if(coverage_dump_enabled && previously == 0) {
			char *key_s;
			asprintf(&key_s, "cmp:%s:%04d:%d:%d", current_filename, current_lineno, current_opcode_pos, (s1_hash & BITMAP_OFFSET_AND));
			if(key_s) {
				char *cov;
				if(is_printable(s1, s1_len))
					asprintf(&cov, "%s:%.*s\n", key_s, s1_len, s1);
				else
					asprintf(&cov, "%s:<unprintable>\n", key_s);
				if(cov) {
					dump_coverage(cov);
					free(cov);
				}
				free(key_s);
			}
		}
	} else {
		// report unmatched strings, could be important
		php_pcov_redqueen_unmatched(s1, s1_len, s2, s2_len);
	}
} /* }}} */

void php_pcov_array_access(char* s1, int len) { /* {{{ */
	uint32_t s1_hash = murmur_hash("s", s1);
	// don't create too many feedback bits, limit it per file:line:opcode 
	// avoids issues where (loop: $_GET[$var] = $bla) or similar
	uint32_t hash = short_hash(5, 0x2222, backtrace_hash, current_lineno, current_opcode_pos, (s1_hash & BITMAP_OFFSET_AND));
	int previously = read_from_trace_buffer(hash & bitmap_mask);
	if(test_feedback_conditions)
		write_to_trace_buffer(hash & bitmap_mask);
	if(coverage_dump_enabled && previously == 0) {
		char *key_s;
		asprintf(&key_s, "array:%s:%04d:%d:%d", current_filename, current_lineno, current_opcode_pos, (s1_hash & BITMAP_OFFSET_AND));
		if(key_s) {
			char *cov;
			if(is_printable(s1, len))
				asprintf(&cov, "%s:%.*s\n", key_s, len, s1);
			else
				asprintf(&cov, "%s:<unprintable>\n", key_s);
			if(cov) {
				dump_coverage(cov);
				free(cov);
			}
			free(key_s);
		}
	}
} /* }}} */

void php_pcov_redqueen_unmatched(char *s1, int len1, char* s2, int len2) {
	if (redqueen_mode_enabled) {
		char buf[1024];
		// [type][len1][s1][len2][s2]
		// type
		if(len1+len2 > 1000) {
			return;
		}
		buf[0] = REDQUEEN_UNMATCHED_STRING;
		// len1
		*(uint16_t*)(buf+1) = len1;
		// s1
		memcpy(buf+3, s1, len1);
		// len2
		*(uint16_t*)(buf+3+len1) = len2;
		// s2
		memcpy(buf+3+len1+2, s2, len2);

		_dump_payload(buf, 3+len1+2+len2, "strings");
	}
}

void php_pcov_redqueen_preg_match(char* regexp, int regexp_len, char* cmp, int cmp_len) {
	if (redqueen_mode_enabled) {
		char buf[1024];
		// [type][cmp_len][regexp][cmp_len][cmp]
		// type
		if(regexp_len+cmp_len > 1000) {
			return;
		}
		buf[0] = REDQUEEN_PREG_MATCH;
		// regexp_len
		*(uint16_t*)(buf+1) = regexp_len;
		// regexp
		memcpy(buf+3, regexp, regexp_len);
		// cmp_len
		*(uint16_t*)(buf+3+regexp_len) = cmp_len;
		// cmp
		memcpy(buf+3+regexp_len+2, cmp, cmp_len);
		_dump_payload(buf, 3+regexp_len+2+cmp_len, "strings");
	}
}

void php_pcov_redqueen(char *s, int len, uint8_t type) {
	// dump the redqueen string content when necessary
	if(redqueen_mode_enabled) {
		dump_redqueen_payload(s, len, type);
	}
}

// returns custom positive feedback using the id and filename:line:opcode as index, e.g. used by substr to report sufficient substr size
void php_pcov_positive_feedback(int id) {
	uint32_t hash = short_hash(5, 0x3333, backtrace_hash, current_lineno, current_opcode_pos, id);
	// don't create too many feedback bits, limit it per file:line:opcode
	// avoids issues where (loop: $_GET[$var] = $bla) or similar
	int previously = read_from_trace_buffer(hash & bitmap_mask);
	if(test_feedback_conditions)
		write_to_trace_buffer(hash & bitmap_mask);
	if(previously == 0 && coverage_dump_enabled) {
		char *key_s;
		asprintf(&key_s, "custom:%02x:%s:%04d:%d\n", id, current_filename, current_lineno, current_opcode_pos);
		if(key_s) {
			dump_coverage(key_s);
			free(key_s);
		}
	}
}

void php_pcov_bug_oracle(char* error_msg, char* type) { /* {{{ */
	// give AFL++ feedback when error happens, maybe this helps to discover new behavior
	if (zend_positive_feedback_callback != NULL)
		zend_positive_feedback_callback(0xcb); //md5("error")[0]

	// if type is already set, someone is reporting an error, we don't need to check
	bool bug_triggered = (type != NULL);
	char *bug_msg = type;
	if(!bug_triggered) {
		// does the user wants us the report a bug on any error?
		if((getenv("NYX_REPORT_ALL_ERRORS") != NULL) && (strstr(error_msg, "undefined") == NULL)) {
			bug_triggered = true;
			bug_msg = "php error";
		}
		// if it failed opening a file containing "crash", we might be able to read/write to arbitrary files
		if((strstr(error_msg, "crash") != NULL) && (strstr(error_msg, "ailed") != NULL) && (strstr(error_msg, "open") != NULL)) {
			bug_triggered = true;
			bug_msg = "arbitrary file open";
		} 
		// lfi required?
		if((getenv("NYX_REPORT_LFI") != NULL) && (getenv("NYX_INCLUDE_ERROR_IS_LFI") != NULL)) {
			// has to include "crash" so we know that we can influence the filename
			if(strstr(error_msg, "crash") != NULL) {
				// has to report an error
				bool inclusion_error = ((strstr(error_msg, "Failed opening") != NULL) && (strstr(error_msg, "for inclusion") != NULL));
				bool opening_error   = ((strstr(error_msg, "failed to open stream") != NULL) && \
				                       ((strstr(error_msg, "include(") != NULL) || (strstr(error_msg, "require(") != NULL) || (strstr(error_msg, "_once(") != NULL)));
				if(inclusion_error || opening_error) {
					// usually LFI errors are reported if crash.php could be included, but it also triggers
					// when the PHP script tries to include a non-existing file that has "crash" in it's name,
					// implying that we have parts of the filename in our control
					bug_triggered = true;
					bug_msg = "lfi";
				}
			} 
		}
		// eval errors required?
		if((getenv("NYX_REPORT_EVAL") != NULL) && (strstr(error_msg, "syntax error") != NULL)) {
			bug_triggered = true;
			bug_msg = "eval";
		}
		// eval with call_user_func?
		if((getenv("NYX_REPORT_EVAL") != NULL) && (strstr(error_msg, "call_user_func") != NULL)) {
			bool not_found = ((strstr(error_msg, "not found or invalid function name") != NULL) && (strstr(error_msg, "crash") != NULL)); 
			bool not_valid = (strstr(error_msg, "to be a valid callback") != NULL);
			if(not_found || not_valid) {
				bug_triggered = true;
				bug_msg = "eval";
			}
		}
		// unserialize errors required?
		if((getenv("NYX_REPORT_UNSERIALIZE") != NULL) && (strstr(error_msg, "unserialize") != NULL) & (strstr(error_msg, "Error at offset") != NULL)) {
			bug_triggered = true;
			bug_msg = "unserialize";
		}
	}

	if(bug_triggered) {
		static uint8_t msg[0x1000] __attribute__((aligned(0x1000)));
		if( access("/tmp/bug_oracle_enabled", F_OK ) == 0 ) {
			// @TODO replace with snprintf? could crash
			sprintf(&msg, "bug oracle triggered: %s (%s:%d) -> %s\n", bug_msg, current_filename, current_lineno, error_msg);
			FILE *f = fopen("/tmp/bug_triggered", "a+");
			if(f) {
				fwrite(msg, 1, strlen(msg), f);
				fclose(f);
			}
		}
	}
} /* }}} */

zend_op_array* php_pcov_compile_file(zend_file_handle *fh, int type) { /* {{{ */
	zend_op_array *result = zend_compile_file_function(fh, type), *mem;

	char abspath[PATH_MAX+1];
	if(realpath(fh->filename, abspath) != NULL && access(abspath, F_OK ) == 0) {
		strncpy(current_filename, abspath, CURRENT_FILENAME_LENGTH-1);
		is_in_eval = (strstr(current_filename, "eval()'d") != NULL);
		MurmurHash3_x86_32(current_filename, strlen(current_filename), 0, &filename_hash);
		update_backtrace_hash();
	} else {
		reset_cov_context();
	}


	if (!result || !result->filename || !php_pcov_wants(result->filename)) {
		return result;
	}

	if (zend_hash_exists(&PCG(files), result->filename)) {
		return result;
	}

	mem = zend_hash_add_mem(
			&PCG(files),
			result->filename,
			result, sizeof(zend_op_array));

#if PHP_VERSION_ID >= 70400
	if (result->refcount) {
		(*result->refcount)++;
	}
	if (result->static_variables) {
		if (!(GC_FLAGS(result->static_variables) & IS_ARRAY_IMMUTABLE)) {
			GC_ADDREF(result->static_variables);
		}
	}
	mem->fn_flags &= ~ZEND_ACC_HEAP_RT_CACHE;
#else
	(void)mem;
	function_add_ref((zend_function*)result);
#endif

	return result;
} /* }}} */

void php_pcov_execute_ex(zend_execute_data *execute_data) { /* {{{ */
	int zrc		= 0;
	if ((execution_limit > 0) && (executed_opcodes > execution_limit))
		return;
	while (1) {
		zrc = php_pcov_trace(execute_data);
		// execution limit reached?
		if (execution_limit > 0) { 
			executed_opcodes += 1;
			if (executed_opcodes > execution_limit) {
				FILE *f = fopen("/tmp/limit_reached", "w+");
				fclose(f);
				reset_cov_context();
				return;
			}
		}

		if (zrc != SUCCESS) {
			if (zrc < SUCCESS) {
				return;
			}
			execute_data = EG(current_execute_data);
		}
	}
} /* }}} */

void php_pcov_covered_dtor(zval *zv) { /* {{{ */
	zend_hash_destroy(Z_PTR_P(zv));
	efree(Z_PTR_P(zv));
} /* }}} */

void php_pcov_files_dtor(zval *zv) { /* {{{ */
	destroy_op_array(Z_PTR_P(zv));
	efree(Z_PTR_P(zv));
} /* }}} */

void php_pcov_filename_dtor(zval *zv) { /* {{{ */
	free(Z_PTR_P(zv));
} /* }}} */

// minit: called when the module loads (when php starts)
// rinit: called for every php file
/* {{{ PHP_MINIT_FUNCTION
 */
PHP_MINIT_FUNCTION(pcov)
{
	//hprintf("minit\n");
	if(current_filename == NULL)
		current_filename = (char*)malloc(CURRENT_FILENAME_LENGTH * sizeof(char));
	if(current_relative_filename == NULL)
		current_relative_filename = (char*)malloc(CURRENT_FILENAME_LENGTH * sizeof(char));
	reset_cov_context();
	short_hash(1, 1); // initialize hash

	if(hashmap_create(8192, &PCG(rq_map)) != 0) {
		hprintf("hashmap_create for rq_map failed\n");
	}
	if(hashmap_create(8192, &PCG(cov_map)) != 0) {
		hprintf("hashmap_create for cov_map failed\n");
	}
	if(hashmap_create(8192, &PCG(string_map)) != 0)  {
		hprintf("hashmap_create for string_map failed\n");
	}

	if(getenv("SHM_ID") == NULL) {
		//hprintf("pcov: SHM_ID not set, can't set trace_buffer\n");
	} else {
		trace_buffer = shmat(atoi(getenv("SHM_ID")), NULL, 0);
		hprintf("pcov init\n");
		hprintf("pcov: SHM_ID: %s\n", getenv("SHM_ID"));
		hprintf("pcov: trace_buffer: %p\n", trace_buffer);
	}
	if(getenv("BITMAP_SIZE") != NULL) {
		bitmap_size = atoi(getenv("BITMAP_SIZE"));
		bitmap_mask = bitmap_size - 1;
		hprintf("pcov: bitmap_size: %x\n", bitmap_size);
		hprintf("pcov: bitmap_mask: %x\n", bitmap_mask);
	}

	REGISTER_NS_LONG_CONSTANT("pcov", "all",         PCOV_FILTER_ALL,     CONST_CS|CONST_PERSISTENT);
	REGISTER_NS_LONG_CONSTANT("pcov", "inclusive",   PCOV_FILTER_INCLUDE, CONST_CS|CONST_PERSISTENT);

	REGISTER_NS_STRING_CONSTANT("pcov", "version",     PHP_PCOV_VERSION,    CONST_CS|CONST_PERSISTENT);

	REGISTER_INI_ENTRIES();

	if (INI_BOOL("pcov.enabled")) {
		zend_execute_ex_function   		  = zend_execute_ex;
		zend_execute_ex            		  = php_pcov_execute_ex;
		enable_custom_feedback_functions();
	}

	ZVAL_LONG(&php_pcov_uncovered,   PHP_PCOV_UNCOVERED);
	ZVAL_LONG(&php_pcov_covered,     PHP_PCOV_COVERED);

	// already enable the module
	PHP_PCOV_API_ENABLED_GUARD();
	PCG(enabled) = 1;

	return SUCCESS;
}
/* }}} */

// called when whole php interpreter exits (not for every php script)
/* {{{ PHP_MSHUTDOWN_FUNCTION
 */
PHP_MSHUTDOWN_FUNCTION(pcov)
{
	disable_custom_feedback_functions();
	reset_cov_context();

	if (INI_BOOL("pcov.enabled")) {
		zend_execute_ex   = zend_execute_ex_function;
	}

	UNREGISTER_INI_ENTRIES();

	return SUCCESS;
}
/* }}} */

const char *php_pcov_directory_defaults[] = { /* {{{ */
	"src",
	"lib",
	"app",
	".",
	NULL
}; /* }}} */

static  void php_pcov_setup_directory(char *directory) { /* {{{ */
	char        realpath[MAXPATHLEN];
	zend_stat_t statbuf;

	if (!directory || !*directory) {
		const char** try = php_pcov_directory_defaults;

		while (*try) {
			if (VCWD_REALPATH(*try, realpath) &&
			    VCWD_STAT(realpath, &statbuf) == SUCCESS) {
				directory = realpath;
				break;
			}
			try++;
		}
	} else {
		if (VCWD_REALPATH(directory, realpath) &&
		    VCWD_STAT(realpath, &statbuf) == SUCCESS) {
			directory = realpath;
		}
	}

	PCG(directory) = zend_string_init(directory, strlen(directory), 0);
} /* }}} */

// rinit: called for every php file
/* {{{ PHP_RINIT_FUNCTION
 */
PHP_RINIT_FUNCTION(pcov)
{
#if defined(COMPILE_DL_PCOV) && defined(ZTS)
	ZEND_TSRMLS_CACHE_UPDATE();
#endif

	reset_cov_context();

	if (!INI_BOOL("pcov.enabled")) {
		return SUCCESS;
	} else {
		enable_custom_feedback_functions();
	}

	PCG(mem) = zend_arena_create(INI_INT("pcov.initial.memory"));

	zend_hash_init(&PCG(files),      INI_INT("pcov.initial.files"), NULL, php_pcov_files_dtor, 0);
	zend_hash_init(&PCG(waiting),    INI_INT("pcov.initial.files"), NULL, NULL, 0);
	zend_hash_init(&PCG(wants),      INI_INT("pcov.initial.files"), NULL, NULL, 0);
	zend_hash_init(&PCG(discovered), INI_INT("pcov.initial.files"), NULL, ZVAL_PTR_DTOR, 0);
	zend_hash_init(&PCG(covered),    INI_INT("pcov.initial.files"), NULL, php_pcov_covered_dtor, 0);

	php_pcov_setup_directory(INI_STR("pcov.directory"));

#ifdef ZEND_COMPILE_NO_JUMPTABLES
	CG(compiler_options) |= ZEND_COMPILE_NO_JUMPTABLES;
#endif

	if  (!zend_compile_file_function) {
		zend_compile_file_function = zend_compile_file;
		zend_compile_file          = php_pcov_compile_file;
	}

	if( access("/tmp/redqueen_mode_enabled", F_OK ) == 0 ) {
		redqueen_mode_enabled = true;
		FILE *r = fopen("/tmp/redqueen_mode_enabled", "rb");
		char buf[100];
		fread(buf, 1, 100, r);
		fclose(r);
		pinned_core = atoi(buf);
	} else {
		redqueen_mode_enabled = false;
	}

	if( access("/tmp/coverage_dump_enabled", F_OK ) == 0 ) {
		coverage_dump_enabled = true;
		FILE *r = fopen("/tmp/coverage_dump_enabled", "rb");
		char buf[100];
		fread(buf, 1, 100, r);
		fclose(r);
		pinned_core = atoi(buf);
	} else {
		coverage_dump_enabled = false;
	}

	if( access("/tmp/execution_limit", F_OK ) == 0 ) {
		FILE *r = fopen("/tmp/execution_limit", "r");
		char buf[100];
		fread(buf, 1, 100, r);
		fclose(r);
		execution_limit = atoi(buf);
	} 

	PCG(start) = NULL;
	PCG(last)  = NULL;
	PCG(next)  = NULL;

	return SUCCESS;
}
/* }}} */

// rshutdown: called for every php file
/* {{{ PHP_RSHUTDOWN_FUNCTION
 */
PHP_RSHUTDOWN_FUNCTION(pcov)
{
	// reset the filename and the lineno once the current execution context ends (bugfix for concat execution)
	reset_cov_context();

	/*
	if (!INI_BOOL("pcov.enabled") || CG(unclean_shutdown)) {
		return SUCCESS;
	}

	zend_hash_destroy(&PCG(files));
	zend_hash_destroy(&PCG(wants));
	zend_hash_destroy(&PCG(discovered));
	zend_hash_destroy(&PCG(waiting));
	zend_hash_destroy(&PCG(covered));
	hashmap_destroy(&PCG(rq_map));

	zend_arena_destroy(PCG(mem));

	if (PCG(directory)) {
		zend_string_release(PCG(directory));
	}
	*/

	disable_custom_feedback_functions();

	if (zend_compile_file == php_pcov_compile_file) {
        zend_compile_file = zend_compile_file_function;
        zend_compile_file_function = NULL;
    }


	return SUCCESS;
}
/* }}} */

/* {{{ PHP_MINFO_FUNCTION
 */
PHP_MINFO_FUNCTION(pcov)
{
	char info[64];
	char *directory = INI_STR("pcov.directory");

	php_info_print_table_start();

	php_info_print_table_header(2,
		"PCOV support",
		INI_BOOL("pcov.enabled")  ? "Enabled" : "Disabled");
	php_info_print_table_row(2,
		"PCOV version",
		PHP_PCOV_VERSION);
	php_info_print_table_row(2,
		"pcov.directory",
		directory && *directory ? directory : (PCG(directory) ? ZSTR_VAL(PCG(directory)) : "auto"));

	snprintf(info, sizeof(info),
		ZEND_LONG_FMT " bytes",
		(zend_long) INI_INT("pcov.initial.memory"));
	php_info_print_table_row(2,
		"pcov.initial.memory", info);

	snprintf(info, sizeof(info),
		ZEND_LONG_FMT,
		(zend_long) INI_INT("pcov.initial.files"));
	php_info_print_table_row(2,
		"pcov.initial.files", info);

	php_info_print_table_end();
}
/* }}} */

static zend_always_inline void php_pcov_report(php_coverage_t *coverage, zval *filter) { /* {{{ */
	zval *table;
	zval *hit;

	if (!coverage) {
		return;
	}

	do {
		if ((table = zend_hash_find(Z_ARRVAL_P(filter), coverage->file))) {
			if ((hit = zend_hash_index_find(Z_ARRVAL_P(table), coverage->line))) {
				Z_LVAL_P(hit) = PHP_PCOV_COVERED;
			}
		}
	} while ((coverage = coverage->next));
} /* }}} */

static void php_pcov_discover_code(zend_arena **arena, zend_op_array *ops, zval *return_value) { /* {{{ */
	zend_cfg cfg;
	zend_basic_block *block;
	zend_op *limit = ops->opcodes + ops->last;
	int i = 0;

	if (ops->fn_flags & ZEND_ACC_ABSTRACT) {
		return;
	}

	memset(&cfg, 0, sizeof(zend_cfg));

	zend_build_cfg(arena, ops,  PHP_PCOV_CFG, &cfg);

	for (block = cfg.blocks, i = 0; i < cfg.blocks_count; i++, block++) {
		zend_op *opline = ops->opcodes + block->start,
			*end = opline + block->len;

		if (!(block->flags & ZEND_BB_REACHABLE)) {
			/*
			* Note that, we don't care about unreachable blocks
			* that would be removed by opcache, because it would
			* create different reports depending on configuration
			*/
			continue;
		}

		while(opline < end) {
			if (!coverage_dump_enabled && php_pcov_ignored_opcode(opline->opcode)) {
				opline++;
				continue;
			}

			if (!zend_hash_index_exists(Z_ARRVAL_P(return_value), opline->lineno)) {
				zend_hash_index_add(
					Z_ARRVAL_P(return_value),
					opline->lineno, &php_pcov_uncovered);
			}

			if ((opline +0)->opcode == ZEND_NEW &&
			    (opline +1)->opcode == ZEND_DO_FCALL) {
				opline++;
			}

			opline++;
		}

		if (block == cfg.blocks && opline == limit) {
			/*
			* If the first basic block finishes at the end of the op array
			* then we don't care about subsequent blocks
			*/
			break;
		}
	}

#if PHP_VERSION_ID >= 80100
    for (uint32_t def = 0; def < ops->num_dynamic_func_defs; def++) {
        php_pcov_discover_code(arena, ops->dynamic_func_defs[def], return_value);
    }
#endif
} /* }}} */

static void php_pcov_discover_file(zend_string *file, zval *return_value) { /* {{{ */
	zval discovered;
	zend_op_array *ops;
	zval *cache = zend_hash_find(&PCG(discovered), file);
	zend_arena *mem;

	if (cache) {
		zval uncached;
		ZVAL_DUP(&uncached, cache);

		zend_hash_update(Z_ARRVAL_P(return_value), file, &uncached);
		return;
	}

	if (!(ops = zend_hash_find_ptr(&PCG(files), file))) {
		return;
	}

	array_init(&discovered);

	mem = zend_arena_create(1024 * 1024);

	php_pcov_discover_code(&mem, ops, &discovered);
	{
		zend_class_entry *ce;
		zend_op_array    *function;
		ZEND_HASH_FOREACH_PTR(EG(class_table), ce) {
			if (ce->type != ZEND_USER_CLASS) {
				continue;
			}

			ZEND_HASH_FOREACH_PTR(&ce->function_table, function) {
				if (function->type == ZEND_USER_FUNCTION &&
				    function->filename &&
				    zend_string_equals(file, function->filename)) {
					php_pcov_discover_code(&mem, function, &discovered);
				}
			} ZEND_HASH_FOREACH_END();
		} ZEND_HASH_FOREACH_END();
	}

	{
		zend_op_array *function;
		ZEND_HASH_FOREACH_PTR(EG(function_table), function) {
			if (function->type == ZEND_USER_FUNCTION &&
			    function->filename &&
			    zend_string_equals(file, function->filename)) {
				php_pcov_discover_code(&mem, function, &discovered);
			}
		} ZEND_HASH_FOREACH_END();
	}

	zend_hash_update(&PCG(discovered), file, &discovered);
	zend_arena_destroy(mem);
	
	php_pcov_discover_file(file, return_value);
} /* }}} */

static zend_always_inline void php_pcov_clean(HashTable *table) { /* {{{ */
	if (table->nNumUsed) {
		zend_hash_clean(table);
	}
} /* }}} */

/* {{{ array \pcov\collect(int $type = \pcov\all, array $filter = []); */
PHP_NAMED_FUNCTION(php_pcov_collect)
{
	zend_long type = PCOV_FILTER_ALL;
	zval      *filter = NULL;

	if (zend_parse_parameters(ZEND_NUM_ARGS(), "|la", &type, &filter) != SUCCESS) {
		return;
	}

	PHP_PCOV_API_ENABLED_GUARD();

	if (PCOV_FILTER_ALL != type &&
	    PCOV_FILTER_INCLUDE != type) {
		zend_throw_error(zend_ce_type_error,
			"type must be "
				"\\pcov\\inclusive, "
				"\\pcov\\exclusive, or \\pcov\\all");
		return;
	}

	array_init(return_value);

	if (PCG(last) == PCG(next)) {
		return;
	}

	PCG(last) = PCG(next);

	switch(type) {
		case PCOV_FILTER_INCLUDE: {
			zval *filtered;
			ZEND_HASH_FOREACH_VAL(Z_ARRVAL_P(filter), filtered) {
				if (Z_TYPE_P(filtered) != IS_STRING) {
					continue;
				}

				php_pcov_discover_file(Z_STR_P(filtered), return_value);
			} ZEND_HASH_FOREACH_END();
		} break;

		case PCOV_FILTER_ALL: {
			zend_string *name;
			ZEND_HASH_FOREACH_STR_KEY(&PCG(files), name) {
				php_pcov_discover_file(name, return_value);
			} ZEND_HASH_FOREACH_END();
		} break;
	}

	php_pcov_report(PCG(start), return_value);
} /* }}} */

/* {{{ void \pcov\start(void) */
PHP_NAMED_FUNCTION(php_pcov_start)
{
	if (zend_parse_parameters_none() != SUCCESS) {
		return;
	}

	PHP_PCOV_API_ENABLED_GUARD();

	PCG(enabled) = 1;
} /* }}} */

/* {{{ void \pcov\stop(void) */
PHP_NAMED_FUNCTION(php_pcov_stop)
{
	if (zend_parse_parameters_none() != SUCCESS) {
		return;
	}

	PHP_PCOV_API_ENABLED_GUARD();

	PCG(enabled) = 0;
} /* }}} */

/* {{{ void \pcov\clear(bool $files = 0) */
PHP_NAMED_FUNCTION(php_pcov_clear)
{
	zend_bool files = 0;

	if (zend_parse_parameters(ZEND_NUM_ARGS(), "|b", &files) != SUCCESS) {
		return;
	}

	PHP_PCOV_API_ENABLED_GUARD();

	if (files) {
		php_pcov_clean(&PCG(files));
		php_pcov_clean(&PCG(discovered));
	}

	zend_arena_destroy(PCG(mem));

	PCG(mem) =
		zend_arena_create(
			INI_INT("pcov.initial.memory"));

	PCG(start) = NULL;
	PCG(last) = NULL;
	PCG(next) = NULL;

	php_pcov_clean(&PCG(waiting));
	php_pcov_clean(&PCG(covered));
} /* }}} */

/* {{{ array \pcov\waiting(void) */
PHP_NAMED_FUNCTION(php_pcov_waiting)
{
	zend_string *waiting;

	if (zend_parse_parameters_none() != SUCCESS) {
		return;	
	}

	PHP_PCOV_API_ENABLED_GUARD();

	array_init(return_value);

	ZEND_HASH_FOREACH_STR_KEY(&PCG(waiting), waiting) {
		add_next_index_str(
			return_value,
			zend_string_copy(waiting));
	} ZEND_HASH_FOREACH_END();
} /* }}} */

/* {{{ int \pcov\memory(void) */
PHP_NAMED_FUNCTION(php_pcov_memory)
{
	zend_arena *arena = PCG(mem);

	if (zend_parse_parameters_none() != SUCCESS) {
		return;
	}

	PHP_PCOV_API_ENABLED_GUARD();

	ZVAL_LONG(return_value, 0);

	do {
		Z_LVAL_P(return_value) += (arena->end - arena->ptr);
	} while ((arena = arena->prev));
} /* }}} */

/* {{{ */
ZEND_BEGIN_ARG_INFO_EX(php_pcov_collect_arginfo, 0, 0, 0)
	ZEND_ARG_TYPE_INFO(0, type, IS_LONG, 0)
	ZEND_ARG_TYPE_INFO(0, filter, IS_ARRAY, 0)
ZEND_END_ARG_INFO() /* }}} */

/* {{{ */
ZEND_BEGIN_ARG_INFO_EX(php_pcov_clear_arginfo, 0, 0, 0)
	ZEND_ARG_TYPE_INFO(0, files, _IS_BOOL, 0)
ZEND_END_ARG_INFO() /* }}} */

/* {{{ */
ZEND_BEGIN_ARG_INFO_EX(php_pcov_no_arginfo, 0, 0, 0)
ZEND_END_ARG_INFO() /* }}} */

/* {{{ php_pcov_functions[]
 */
const zend_function_entry php_pcov_functions[] = {
	ZEND_NS_FENTRY("pcov", start,      php_pcov_start,         php_pcov_no_arginfo, 0)
	ZEND_NS_FENTRY("pcov", stop,       php_pcov_stop,          php_pcov_no_arginfo, 0)
	ZEND_NS_FENTRY("pcov", collect,    php_pcov_collect,       php_pcov_collect_arginfo, 0)
	ZEND_NS_FENTRY("pcov", clear,      php_pcov_clear,         php_pcov_clear_arginfo, 0)
	ZEND_NS_FENTRY("pcov", waiting,    php_pcov_waiting,       php_pcov_no_arginfo, 0)
	ZEND_NS_FENTRY("pcov", memory,     php_pcov_memory,        php_pcov_no_arginfo, 0)
	PHP_FE_END
};
/* }}} */

/* {{{ pcov_module_deps[] */
static const zend_module_dep pcov_module_deps[] = {
	ZEND_MOD_END
}; /* }}} */

/* {{{ pcov_module_entry
 */
zend_module_entry pcov_module_entry = {
	STANDARD_MODULE_HEADER_EX,
	NULL,
	pcov_module_deps,
	"pcov",
	php_pcov_functions,
	PHP_MINIT(pcov),
	PHP_MSHUTDOWN(pcov),
	PHP_RINIT(pcov),
	PHP_RSHUTDOWN(pcov),
	PHP_MINFO(pcov),
	PHP_PCOV_VERSION,
	PHP_MODULE_GLOBALS(pcov),
	PHP_GINIT(pcov),
	NULL,
	NULL,
	STANDARD_MODULE_PROPERTIES_EX
};
/* }}} */

#ifdef COMPILE_DL_PCOV
#ifdef ZTS
ZEND_TSRMLS_CACHE_DEFINE()
#endif
ZEND_GET_MODULE(pcov)
#endif

/*
 * Local variables:
 * tab-width: 4
 * c-basic-offset: 4
 * End:
 * vim600: noet sw=4 ts=4 fdm=marker
 * vim<600: noet sw=4 ts=4
 */
