<?php

namespace App {

   require_once(__DIR__ . "/../../vendor/autoload.php");

   use PhpParser\Parser;
   use PhpParser\ParserFactory;
   use PhpParser\Node;
   use PhpParser\NodeVisitorAbstract;
   use MyCLabs\Enum\Enum;

   class OutputMethod extends Enum {
      private const HTTP = 'http';
      private const FILE = 'file';
      private const SHM_MEM = 'shm_memory';
   }

   class InstrumentPolicy extends Enum {
      private const NODE = 'node';
      private const EDGE = 'edge';
      private const NODE_EDGE = 'node-edge';
      private const PATH = 'path';
   }

   abstract class BasicBlockVisitorAbstract extends NodeVisitorAbstract {
      public    OutputMethod $output;
      public    int $numBlocksInstrumented = 0;
      protected int $level = 0;
      protected Parser $parser;

      function __construct(OutputMethod $output) {
         $this->output = $output;
         $this->parser = (new ParserFactory)->create(ParserFactory::PREFER_PHP7);
      }

      public function codeToNodes(string $code) {
         $code = "<?php \n".$code;
         $stmts = $this->parser->parse($code);
         return $stmts;
      }

      abstract protected function makeBasicBlockStub();
      abstract protected function makeModuleStubFile();
      abstract protected function makeModuleStubHttp();

      /**
       * Runs before we start the tree traversal
       *
       * @param array   $nodes   the top-level nodes
       * @return array  The modified set of nodes
       */
      public function beforeTraverse(array $nodes): ?array {
          return null;
      }

      /** 
       * Runs after we visited all nodes in the tree
       *
       * This function will insert the instrumentation header at the start of the file
       * There are two versions of the header:
       *       2) write feedback to regular file
       *       3) use of HTTP Header to sent deltas('changes in table') rather than full table
       *
       * @param array   $nodes   the top-level nodes
       * @return array  The modified set of nodes
       */
      public function afterTraverse(array $nodes): ?array {

         $header = [];

         if ($this->output == OutputMethod::FILE())
            $header = $this->makeModuleStubFile();
         elseif ($this->output == OutputMethod::HTTP())
            $header = $this->makeModuleStubHttp();

         for ($stmtStart = 0; $stmtStart < count($nodes); $stmtStart++) {
            // cannot insert before declare statements
            if ($nodes[$stmtStart] instanceof Node\Stmt\DeclareDeclare ||
                $nodes[$stmtStart] instanceof Node\Stmt\Declare_)
               continue;

            if ($nodes[$stmtStart] instanceof Node\Stmt\Namespace_) {
               # file contains namespace declaration
               # thus include the header stub inside
               # the namespace's statements and exit.
               $nodes[$stmtStart]->stmts = array_merge($header, 
                                                       $this->makeBasicBlockStub(), 
                                                       $nodes[$stmtStart]->stmts);
               return $nodes;
            } else
               # no namespace statements are used
               # so just simply prepend the header stub
               # as another top-level statement
               return array_merge(array_splice($nodes, 0, $stmtStart),
                                  $header,
                                  $this->makeBasicBlockStub(),
                                  $nodes);
         }

         return $nodes;
      }

      /** 
       * Runs at the moment we traverse forwards into a deeper point in the tree
       *
       * @param Node   $node   the current node that we will go forward from
       * @return ?Node         possible modified version of it. null indicates no changes
       */
      public function enterNode(Node $node): ?Node {
         if (! $node instanceof Node\Stmt\ElseIf_ &&
             ! $node instanceof Node\Stmt\Else_ &&
             ! $node instanceof Node\Stmt\Catch_) {
            // these statements reside inside a Stmt\If_ thus
            // the true if condition will have one level lower than the
            // elseif/else condition. as a fix don't increase the level
            $this->level++;
         }

         return null;
      }

      /** 
       * Runs at the moment we traverse backwards from a deeper point in the tree
       *
       * @param Node   $node   the current node we will leave from
       * @return ?array        possible modified version of it. null indicates no changes
       */
      public function leaveNode(Node $node) {
         // TODO: support GOTO stmts, 

         // empty functions/methods could mean they are abstract so avoid them
         // otherwise instrumenting empty methods/functions only increases overhead
         // with no usefulness
         if (($node instanceof Node\Stmt\ClassMethod ||
              $node instanceof Node\Stmt\Function_ ||
              $node instanceof Node\FunctionLike) && empty($node->stmts)) {
            $this->level--;
            return $node;
         }

         if ($node instanceof Node\Stmt\If_ ||
             $node instanceof Node\Stmt\ElseIf_ ||
             $node instanceof Node\Stmt\Else_ ||
             $node instanceof Node\Stmt\TryCatch ||
             $node instanceof Node\Stmt\Catch_ ||
             $node instanceof Node\Stmt\Do_ ||
             $node instanceof Node\Stmt\While_ ||
             $node instanceof Node\Stmt\For_ ||
             $node instanceof Node\Stmt\Foreach_ ||
             $node instanceof Node\Stmt\Case_ ||
             $node instanceof Node\FunctionLike ||
             $node instanceof Node\Stmt\Function_ ||
             $node instanceof Node\Stmt\ClassMethod)
            $node->stmts = array_merge($this->makeBasicBlockStub(), $node->stmts);

         if (! $node instanceof Node\Stmt\ElseIf_ &&
             ! $node instanceof Node\Stmt\Else_ &&
             ! $node instanceof Node\Stmt\Catch_) {
            $this->level--;
         }

         if ($node instanceof Node\Stmt\If_ ||
             $node instanceof Node\Stmt\TryCatch ||
             $node instanceof Node\Stmt\Do_ ||
             $node instanceof Node\Stmt\While_ ||
             $node instanceof Node\Stmt\For_ ||
             $node instanceof Node\Stmt\Foreach_ ||
             $node instanceof Node\Stmt\Switch_ ||
             $node instanceof Node\Stmt\Label)
            return array_merge([$node], $this->makeBasicBlockStub());
         else
            return $node;
      }
   }
}