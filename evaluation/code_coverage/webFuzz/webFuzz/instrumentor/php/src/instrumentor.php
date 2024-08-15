#!/bin/env php
<?php

require_once(__DIR__ . "/../vendor/autoload.php");

ini_set('xdebug.max_nesting_level', 10000);
ini_set('memory_limit', -1);
set_time_limit(0);

use PhpParser\NodeTraverser;
use PhpParser\ParserFactory;
use PhpParser\PrettyPrinter;

use App\Argparser;
use App\OutputMethod;
use App\InstrumentPolicy;
use App\FileSystem;


$args = (new Argparser($argv[0]))->options;

# prepare directory
$newDir = FileSystem::makeFolderName($args->dir, "_instrumented");
foreach ($args->excludedFiles as &$fileName) {
   $fileName = $newDir . '/' . $fileName;
   echo 'Not instrumenting: '. $fileName. PHP_EOL;
}
   
FileSystem::copyFolderRecursive($args->dir, $newDir);
$args->dir = $newDir;

$files = FileSystem::getPhpFilesRecursive($args->dir, $args->excludedFiles);

# start instrumenting
$parser = (new ParserFactory)->create(ParserFactory::PREFER_PHP7);
$prettyPrinter = new PrettyPrinter\Standard;
$errors = [];
$numBlocksInstrumented = 0;

foreach ($files as $_ => $file) {
   try {      
      switch ($args->policy) {
         case InstrumentPolicy::NODE():
            $visitor = new NodeVisitor($args->output);
            break;
         case InstrumentPolicy::EDGE():
            $visitor = new EdgeVisitor($args->output);
            break;
         case InstrumentPolicy::NODE_EDGE():
            $visitor = new NodeEdgeVisitor($args->output);
            break;
         case InstrumentPolicy::PATH():
            $visitor = new PathVisitor($args->output);
            break;
         }
        
      $traverser = new NodeTraverser;
      $traverser->addVisitor($visitor);

      $code = file_get_contents($file);
      $stmts = $parser->parse($code);
      $instrumentedCode = $traverser->traverse($stmts);
      $prettyCode = $prettyPrinter->prettyPrintFile($instrumentedCode);

      file_put_contents($file, $prettyCode);

      $numBlocksInstrumented += $visitor->numBlocksInstrumented;
      if ($args->verbose)
         echo '[✓] Instumenting: '.$file."\n";

   } catch (PhpParser\Error $e) {
      $error = 'Instrument Error on '.$file.': '.$e->getMessage();
      $errors[] = $error;
      if ($args->verbose)
         echo '[x] Instumenting: '.$file."\n";
   } catch (\Throwable $e) {
      $error = 'Unknown error detected at '.$file.": ".$e->getMessage(); 
      $errors[] = $error;
      if ($args->verbose)
         echo '[x] Instumented: '.$file."\n";
   }
}

echo PHP_EOL;
echo "==> Instrumentation finished".PHP_EOL;
echo "==> Number of Instrumented Basic Blocks: ". $numBlocksInstrumented.PHP_EOL;

# report any errors
if (count($errors) > 0) {
   error_log("==> The following errors were encountered. Files that produced an error were not instrumented".PHP_EOL);
   foreach ($errors as $e)
      error_log("  - ".$e, 0);
} else {
   echo "==> No errors were encountered".PHP_EOL;
}

if ($args->output == OutputMethod::FILE())
   echo "==> Feedback will be written in '/var/instr/'. Make sure it is writable".PHP_EOL;


# create meta file
$meta = array("basic-block-count" =>  $numBlocksInstrumented - 1,
              "output-method" => $args->output,
              "instrument-policy" => $args->policy);

if ($args->policy == InstrumentPolicy::EDGE() || 
    $args->policy == InstrumentPolicy::NODE_EDGE()) {
   // Calculate an estimate on the total number of possible CFG edges
   $edges = pow(2, ceil(log($numBlocksInstrumented - 1, 2)));
   $meta["edge-count"] = $edges;
}

file_put_contents($args->dir . "/instr.meta", json_encode($meta));
