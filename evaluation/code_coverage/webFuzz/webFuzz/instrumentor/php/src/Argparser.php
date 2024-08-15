<?php

namespace App {

require_once(__DIR__ . "/../vendor/autoload.php");

class ArgumentParserException extends \Exception {};

class Options {
   public string $dir;
   public OutputMethod $output;
   public InstrumentPolicy $type;
   public bool $verbose = false;
   public array $excludedFiles = [];
}

class Argparser {
   public string $programName;
   public Options $options;

   public function __construct(string $programName) {
      $this->programName = $programName;
      $this->parse();
   }

   public function usage():void {
      echo "Usage: $this->programName [--help] | [--verbose] [--method STR] [--policy STR] --dir STR 
PHP Code Instrumentor

Required arguments:
   --dir                The src directory to instrument

Optional arguments:
   --help               Show this help message and exit

   --verbose            Be verbose

   --method             The output method: file,http
                           Default: file

   --exclude            Filename with path names (relative to --dir)
                        of directories/files to exclude (separated by a newline character)

   --policy             The type of instrumentation: node,edge,node-edge,path
                           Default: node\n";
      exit(1);
   }


   private function parse(): self {
      $long_opts = array(
         "dir:",
         "method:",
         "policy:",
         "verbose",
         "exclude:"
      );
      
      $options = getopt("", $long_opts);
      if (empty($options["dir"])   ||
          isset($options["help"]))
         $this->usage();
      
      $args = new Options();

      $args->dir = $options["dir"];
      $args->verbose = isset($options["verbose"]);
      $args->output = new OutputMethod($options["method"] ?? "file");
      $args->policy = new InstrumentPolicy($options["policy"] ?? "node");

      if (isset($options["exclude"]) && \file_exists($options["exclude"])) {
         $args->excludedFiles = array_filter(explode("\n", file_get_contents($options["exclude"])));
      }

      $this->options = $args;

      return $this;
   }
}

}

