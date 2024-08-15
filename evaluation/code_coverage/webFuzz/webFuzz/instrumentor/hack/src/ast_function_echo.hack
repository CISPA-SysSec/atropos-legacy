namespace Facebook\HHAST;
use namespace HH\Lib\{C, Vec, Str};
use function Facebook\HHAST\__Private\whitespace_from_nodelist;

require_once(__DIR__."/../vendor/autoload.hack");
/* Used code from:
    hhvm/hhast/blob/master/src/Migrations/BaseMigration.hack
    hhvm/hhast/blob/master/src/Migrations/prepend_statements.hack
    hhvm/hhast/blob/master/src/Migrations/HSLMigration.hack
*/
function nodeFromCode<T as Node>(
    string $code,
    classname<T> $expected,
  ): T {
    $script = \HH\Asio\join(
      from_file_async(File::fromPathAndContents('/dev/null', $code)),
    );
    $node = $script->getDeclarations()->getFirstDescendantOfType($expected);
    invariant(
      $node !== null,
      "Failed to find node of type '%s' in code '%s'",
      $expected,
      $code,
    );
    return $node;
}

function prepend_statements(
  Script $root,
  vec<IStatement> $new,
  Node $before,
): Script {
  if (C\is_empty($new)) {
    return $root;
  }

  // Find the closest parent block.
  $ancestors = $root->getAncestorsOfDescendant($before);
  for ($i = C\count($ancestors) - 1; $i >= 0; --$i) {
    if ($ancestors[$i] is IStatement) {
      break;
    }
  }
  for (--$i; $i >= 0; --$i) {
    if ($ancestors[$i] is NodeList<_>) {
      break;
    }
  }
  invariant(
    $i >= 0,
    'Failed to find any parent NodeList of any parent Statement.',
  );

  $parent_block = $ancestors[$i] as NodeList<_>;
  $old = $parent_block->getChildren();
  for ($before_idx = 0; $before_idx < C\count($old); ++$before_idx) {
    if ($old[$before_idx] === $ancestors[$i + 1]) {
      break;
    }
  }
  invariant(
    $before_idx < C\count($old),
    'Failed to find the provided statement in the parent block. This should '.
    'never happen.',
  );

  // Move leading trivia (both whitespace and comments) from the current
  // statement to the first statement being prepended -- i.e. we want to insert
  // the new statements _inbetween_ the current statement and its leading
  // trivia.
  
  $new[0] = $new[0]->replace(
    $new[0]->getFirstTokenx(),
    $new[0]->getFirstTokenx()
      ->withLeading($old[$before_idx]->getFirstTokenx()->getLeading()),
  );

  $old[$before_idx] = $old[$before_idx]->replace(
    $old[$before_idx]->getFirstTokenx(),
    $old[$before_idx]->getFirstTokenx()->withLeading(null),
  );

/*
  // Put an autodetected (via whitespace_from_nodelist) amount of whitespace
  // between each pair of statements.
  $whitespace = whitespace_from_nodelist($root, $parent_block);
  foreach ($new as $idx => $statement) {
    $new[$idx] = $statement->replace(
      $statement->getLastTokenx(),
      $statement->getLastTokenx()->withTrailing($whitespace['between']),
    );
  }
*/
  return $root->replace(
    $parent_block,
    NodeList::createMaybeEmptyList(
      Vec\concat(
        Vec\take($old, $before_idx),
        $new,
        Vec\drop($old, $before_idx),
      ),
    ),
  );
}

function printQualifiedName(QualifiedName $item) : string {
    $str = "";
    //   echo \get_class($child->getSeparator());
    foreach ($item->getParts()->getChildren() as $list_item) {
      if ($list_item->getItem() is NameToken) 
          $str .= $list_item->getItem()->getText();
      if ($list_item->getSeparator() is BackslashToken)
          $str .= "\\";
    }

   return $str;
}
function getFunctionCallName(FunctionCallExpression $node): ?string {
    $receiver = $node->getReceiver();

    if ($receiver is NameToken) 
      return $receiver->getText();
    else if ($receiver is QualifiedName) 
      return printQualifiedName($receiver);
    else if ($receiver is ScopeResolutionExpression) {
      return $receiver->getName()->getText();
    } else if ($receiver is MemberSelectionExpression) {
        $name = $receiver->getName()->getFirstToken();
        if ($name is NameToken)
          return $name->getText();
        if ($name is QualifiedName)
          return printQualifiedName($name);
    }

    // unkown function call type detected    
    return null;
}

function migrateFile(Script $ast, string $filename): Script {
    // find all the function calls
    $nodes = $ast->getDescendantsOfType(FunctionCallExpression::class);
    
    foreach ($nodes as $node) {

      //echo \get_class($node)."\n";

      $name = getFunctionCallName($node);
      if ($name is null)
          continue;

      echo $name."\n";
      $echo_node = nodeFromCode("echo 'function $name in $filename';", \Facebook\HHAST\EchoStatement::class);
      $ast = prepend_statements($ast, vec[$echo_node], $node);
    }

    return $ast;
}


async function statementFromCodeAsync(string $code): Awaitable<IStatement> {
    $script = await from_file_async(
      File::fromPathAndContents('/dev/null', $code),
    );
    return $script->getDeclarations()->getChildren()
      |> firstx($$) as IStatement;
}

function getBasename(string $path) : string {
    $parts = Str\split($path, "/");
    return $parts[C\Count($parts)-1];
}

function getDirname(string $path) : string {
    $parts = Str\split($path, "/");
    if (C\Count($parts) <= 1)
      return "";

    return Str\join(Vec\take($parts, C\Count($parts)-1),"/")."/";
}

<<__EntryPoint>>
async function runner() : Awaitable<noreturn> {
    \Facebook\AutoloadMap\initialize();

    $file = "./BaseMigration.hack";
    $newfile = getDirname($file)."instr.".getBasename($file);

    try {
      $ast = \HH\Asio\join(from_file_async(File::fromPath($file)));
    } catch (ASTError $e) {
      \HH\Asio\join($this->getStderr()->writeAsync($e->getMessage()));
      exit(1);
    }

    $new_ast = migrateFile($ast, $file);
    if ($ast !== $new_ast) {
      $ast = $new_ast;
      \file_put_contents($newfile, $ast->getCode());
    }

    exit(0);
}


