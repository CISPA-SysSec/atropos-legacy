# This is the agent portion of Atropos (runs inside the VM and interacts with the fuzzer and the PHP interpreter)
import osproc
import std/os
import std/strformat
import fastcgi/client
import std/json
import std/[strutils, os]
import std/algorithm
import net
import posix

{.compile: "nyx.c".}
proc executed_in_vm(): cint {.importc.}
proc capabilites_configuration(a: bool, b: bool, c: bool): void {.importc.}
proc nyx_init(): void {.importc.}
proc nyx_create_snapshot(): void {.importc.}
proc nyx_exit(): void {.importc.}
proc nyx_get_trace_buffer(): pointer {.importc}
proc nyx_get_payload(): cstring {.importc}
proc nyx_get_payload_len(): uint32  {.importc.}
proc nyx_is_payload_null(): cint {.importc.}
proc nyx_get_bitmap_size(): uint32 {.importc.}
proc nyx_get_shm_id(): cint {.importc.}
proc nyx_set_bitmap(key: uint32, offset: uint32): void {.importc.}
proc nyx_report_crash(msg: cstring): void {.importc.}
proc nyx_html_dump(buffer: cstring, len: uint32, pinned_core: uint32): void {.importc.}

const MAX_OPCACHE_FILES = 0 
const SECRET_READ_TRIGGER = "secret4815162342"
const SECRET_WRITE_TRIGGER = "secret_write_trigger"
var modified_files {.threadvar.}: seq[string]

# https://github.com/juancarlospaco/nim-crc32/blob/master/src/crc32.nim
func createCrcTable(): array[0..255, uint32] =
  for i in 0.uint32..255.uint32:
    var rem = i
    for j in 0..7:
      if (rem and 1) > 0'u32: rem = (rem shr 1) xor uint32(0xedb88320)
      else: rem = rem shr 1
    result[i] = rem

template updateCrc32(c: char; crc: var uint32) =
  crc = (crc shr 8) xor static(createCrcTable())[uint32(crc and
      0xff) xor uint32(ord(c))]

func crc32*(input: var string): uint32 =
  var crcuint = uint32(0xFFFFFFFF)
  for c in input: updateCrc32(c, crcuint)
  crcuint = not crcuint
  return crcuint

proc sort_by_filesize(x, y: string): int =
  if getFileSize(x) > getFileSize(y):
      return 1
  else:
      return -1

proc get_write_oracle_crc(): uint32 =
    # remember the crc/hash of crash.php for the file-write bug oracle
    let arbitrary_write_oracle_file = "/var/www/html/crash.php"
    var crash_file_crc: uint32 = 0
    if fileExists(arbitrary_write_oracle_file):
        var crash_file_content = readFile(arbitrary_write_oracle_file)
        crash_file_crc = crc32(crash_file_content)
    return crash_file_crc

proc start_php_interpreter(activate_bug_oracles: bool): void =
    var e = fmt"IN_NYX=1 SHM_ID={nyx_get_shm_id()} BITMAP_SIZE={nyx_get_bitmap_size()} SERVER_NAME=localhost REDIRECT_STATUS=1 PHP_FCGI_CHILDREN=0 PHP_FCGI_MAX_REQUESTS=0 LD_LIBRARY_PATH=/tmp/ LD_BIND_NOW=1 /tmp/target_executable -b /tmp/php.sock -c /tmp/php.ini &" # | /tmp/hcat 2>&1
    if activate_bug_oracles:
        # NYX_REPORT_ALL_ERRORS (every error is a crash)
        # NYX_REPORT_LFI (lfi bug oracle activated)
        # NYX_INCLUDE_ERROR_IS_LFI (treat every inclusion error as an LFI crash)
        # NYX_REPORT_EVAL (eval bug oracle activated)
        # NYX_REPORT_SQL_INJECTION (sql injection oracle activated, only for syntax errors)
        # NYX_REPORT_ALL_SQL_INJECTION (all sql errors trigger the bug oracle)
        # NYX_REPORT_UNSERIALIZE (unserialize vulnerability oracle activated)
        e = "NYX_REPORT_LFI=1 NYX_INCLUDE_ERROR_IS_LFI=1 NYX_REPORT_EVAL=1 NYX_REPORT_SQL_INJECTION=1 NYX_REPORT_UNSERIALIZE=1" & e;
    discard execCmd(e)
    sleep(3000)

proc report_crashes_if_necessary(log: string): void =
    var crash_log = ""
    crash_log &= log
    # did pcov report crashes?
    if fileExists("/tmp/bug_triggered"):
        let bug_msg = readFile("/tmp/bug_triggered")
        crash_log &= fmt("{bug_msg}")
        
    if crash_log != "":
        nyx_report_crash($fmt"{crash_log}")

nyx_init()

discard execCmd("chown -R mysql:mysql /var/lib/mysql /var/run/mysqld; service mysql restart") #mysqld --innodb-thread-sleep-delay=0 & ")
discard execCmd("chmod -R 777 /var/lib/php/sessions/")
sleep(3000)
# start the php interpreter in fastcgi mode
start_php_interpreter(true) # without bug oracles for preloading

discard execCmd("chmod -R 777 /var/lib/php/sessions/")
# preload all files (or a sample of all files)
var files: seq[string]
for file in walkDirRec("/var/www/html/"):
    files.add(file)
# Sorting with custom proc
files.sort(sort_by_filesize)
files.reverse()
# but make sure everything in the root directory is preloaded
for file in walkFiles("/var/www/html/*"):
    files.insert(file, 0)
var max_it = files.high
if MAX_OPCACHE_FILES > 0:
    max_it = min(MAX_OPCACHE_FILES, files.high)
for php_file in files[files.low..max_it]:
    if not php_file.endsWith(".php") or php_file.endsWith("crash.php") or php_file.contains("logout"):
        continue
    let cl2 = newFCGICLientUnix("/tmp/php.sock") 
    cl2.connect()
    cl2.setParams({
        "REDIRECT_STATUS": "1",
        "QUERY_STRING": "",
        "SCRIPT_FILENAME": php_file,
        "REQUEST_METHOD": "GET",
        "CONTENT_LENGTH": "0",
        "CONTENT_TYPE": "application/x-www-form-urlencoded",
        "POST_DATA": "",
        "HTTP_COOKIE": "",
        "SERVER_NAME": "localhost:8000",
        "SERVER_PORT": "8000",
        "SERVER_ADDR": "localhost:8000",
        "QUERY_STRING": "",
        "CONTENT_LENGTH": "0",
        "HTTP_COOKIE": "",
        "SCRIPT_NAME": php_file.replace("/var/www/html/", ""),
        "REQUEST_URI": "http://localhost:8000/",
        "HTTP_HOST": "localhost:8000"
    })
    try:
        discard cl2.sendRequest("")
    except:
        discard execCmd(fmt"echo php-nim: php crashed while preloading {php_file} | /tmp/hcat")
        start_php_interpreter(true) 
    finally:
        cl2.close()
sleep(2000)

# enable bug oracle reporting after cache is loaded
discard execCmd("touch /tmp/bug_oracle_enabled")

let arbitrary_write_oracle_crc_before = get_write_oracle_crc()
var crash_log = ""

discard execCmd("cat /webfuzz_cov.txt | tail -n 50 2>&1 | /tmp/hcat")
discard execCmd("cp /webfuzz_cov.txt /dev/shm/ 2>&1 | /tmp/hcat")
discard execCmd("/tmp/target_executable -c /tmp/php.ini -i | grep extension_dir 2>&1 | /tmp/hcat")
nyx_create_snapshot()

if nyx_get_payload_len() > 0:
    let payload: string = fmt"{nyx_get_payload()}"
    let jsonNode = parseJson(payload)
    # read general config (e.g. is redqueen mode enabled? etc)
    let config = jsonNode["config"]
    var redqueen_core = 0
    var redqueen_mode = false
    var html_dump_mode = false
    for key in config.keys():
        if key == "REDQUEEN":
            redqueen_core = parseInt(config[key].getStr())
            redqueen_mode = true
            writeFile("/tmp/redqueen_mode_enabled", config[key].getStr()&chr(0x00))
        elif key == "COVERAGE_DUMP":
            writeFile("/tmp/coverage_dump_enabled", config[key].getStr()&chr(0x00))
        elif key == "HTML_DUMP":
            html_dump_mode = true
        elif key == "EXEC_LIMIT":
            writeFile("/tmp/execution_limit", config[key].getStr()&chr(0x00))

    for envs in jsonNode["requests"].items():
        # connect to fastcgi server
        # create new instance
        let cl = newFCGICLientUnix("/tmp/php.sock") 
        cl.connect()
        var filename: string = ""
        for key in envs.keys():
            if key == "SCRIPT_FILENAME":
                filename = envs[key].getStr()
            if key != "POST_DATA" and not key.startsWith("_RAW"):
                cl.setParam(key, envs[key].getStr())
        # send stdin payload
        var output = ""
        try:
            output = cl.sendRequest(envs["POST_DATA"].getStr())
        except:
            nyx_exit()

        let split = output.split("\r\n\r\n", 1)
        var header = ""
        var content = output # in case splitting doesn't work, use all of it
        if len(split) > 1:
            header = split[0]
            if len(split[1]) > 0:
                content = split[1]
        
        let bitmap_key_file: uint32 = crc32(filename)

        if content.contains(SECRET_READ_TRIGGER):
            crash_log &= fmt("bug oracle triggered: validated arbitrary read in {filename}\n")
        
        for f in modified_files:
            # give feedback that a php file was added or modified
            let modified_file_id: uint32 = crc32(output)
            nyx_set_bitmap(bitmap_key_file, modified_file_id)
            # if the file exists, look to see if it contains a magic string
            # which indicates that we control the input (rce/eval bug)
            if fileExists(f):
                var crash_file_content = readFile(f)
                if SECRET_WRITE_TRIGGER in crash_file_content:
                    crash_log &= fmt("bug oracle triggered: validated file write to eval in {filename}\n")

        let arbitrary_write_oracle_crc_after = get_write_oracle_crc()
        if arbitrary_write_oracle_crc_before != arbitrary_write_oracle_crc_after:
            crash_log &= fmt("bug oracle triggered: validated arbitrary file write/delete/rename in {filename}\n")

        if html_dump_mode:
            nyx_html_dump($output, uint32(len(output)), uint32(redqueen_core))

        # execution limit reached? exit immediately
        if fileExists("/tmp/limit_reached"):
            report_crashes_if_necessary(crash_log)
            nyx_exit()

        # close connection
        cl.close()
    report_crashes_if_necessary(crash_log)

nyx_exit()