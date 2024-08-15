/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace Facebook\HHAST;

use namespace HH\Lib\C;
use type Facebook\HHAST\Script;

<<__ConsistentConstruct>>
abstract class BaseMigration {
  public function __construct(private string $root) {
  }

  final protected function getRoot(): string {
    return $this->root;
  }

  /**
   * Subclasses can override these if they depend on a specific HHVM version or
   * .hhconfig option.
   */
  public static function getMinimumHHVMVersion(): ?string {
    return null;
  }

  /**
   * If your subclass returns any .hhconfig options here, also add the same
   * options to your test's migration_name.hack.hhconfig file.
   */
  public static function getRequiredHHConfigOptions(): dict<string, string> {
    return dict[];
  }

  abstract public function migrateFile(string $path, Script $ast): Script;

  protected static async function expressionFromCodeAsync(
    string $code,
  ): Awaitable<IExpression> {
    $script = await from_file_async(
      File::fromPathAndContents('/dev/null', '$_='.$code.';'),
    );
    return $script->getDeclarations()
      ->getChildren()
      |> C\firstx($$) as ExpressionStatement
      |> $$->getExpression() as BinaryExpression
      |> $$->getRightOperand();
  }

  protected static async function statementFromCodeAsync(
    string $code,
  ): Awaitable<IStatement> {
    $script = await from_file_async(
      File::fromPathAndContents('/dev/null', $code),
    );
    return $script->getDeclarations()->getChildren()
      |> C\firstx($$) as IStatement;
  }
}
