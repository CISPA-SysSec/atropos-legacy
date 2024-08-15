<?php

require_once(__DIR__ . "/../../vendor/autoload.php");

use App\BasicBlockVisitorAbstract;

class EdgeVisitor extends BasicBlockVisitorAbstract {
   protected function makeBasicBlockStub() {
      $uid = random_int(256, 268435456);
      $this->numBlocksInstrumented += 1;

      $code = '$____key = '.$uid.' ^ $GLOBALS["____instr"]["prev"];'.
              'isset($GLOBALS["____instr"]["map"][$____key]) ?: $GLOBALS["____instr"]["map"][$____key] = 0;'.
              '$GLOBALS["____instr"]["map"][$____key] += 1;'.
              '$GLOBALS["____instr"]["prev"] = '. ($uid >> 1) .';'.
              '$u_561 = "cov:".__FILE__.":".__LINE__.":0\n";'.
              'if (strpos(file_get_contents("/dev/shm/webfuzz_cov.txt"), $u_561) === false) { file_put_contents("/dev/shm/webfuzz_cov.txt", $u_561, FILE_APPEND | LOCK_EX); }';

      return $this->codeToNodes($code);
   }

   protected function makeModuleStubFile() {
      // Request ID should be provided by Http Header Req-Id, e.g. Req-Id: 12345

      $code = 'if (! array_key_exists("____instr", $GLOBALS)) {'.
              '   $GLOBALS["____instr"]["map"] = array();'.
              '   $GLOBALS["____instr"]["prev"] = 0;'.
              '   function ____instr_write_map() {'.
              '      $f = fopen("/var/instr/map." . (isset($_SERVER["HTTP_REQ_ID"]) ? $_SERVER["HTTP_REQ_ID"] : 0), "w+");'.
              '      foreach ($GLOBALS["____instr"]["map"] as $k=>$v) {'.
              '          fwrite($f, $k . "-" . $v . "\n");'.
              '      }'.
              '      fclose($f);'.
              '   }'.
              '   register_shutdown_function("____instr_write_map");'.
              '}';

      return $this->codeToNodes($code);
   }

   protected function makeModuleStubHttp() {
      // (ob_start(null, 0, 0) 
      //     takes care of output_buffering. By inserting it at top-most level
      //     all output is captured here before sent to browser thus allowing header editing, 
      //     + disallowing any calls to flush it by ob_*_flush() also helps in case the app 
      //       tries to flush all buffers

      $code = 'if (! array_key_exists("____instr", $GLOBALS)) {'.
              '   $GLOBALS["____instr"]["map"] = array();'.
              '   $GLOBALS["____instr"]["prev"] = 0;'.
              '   function ____instr_write_map() {'.
              '      foreach ($GLOBALS["____instr"]["map"] as $k=>$v) {'.
              '          header("I-" . $k . ": " . $v);'.
              '      }'.
              '   }'.
              '   register_shutdown_function("____instr_write_map");'.
              '   ob_start(null, 0, 0);'.
              '}';

      return $this->codeToNodes($code);
   }
}
