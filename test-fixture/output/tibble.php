<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<af7b462f2c87d7226a1f1b8c3f6ff699>>
 */
namespace _catarini_test;
use namespace catarini\db;
use type catarini\db\Type;
use type catarini\db\schema\Table;
use type catarini\db\schema\Column;
use type catarini\db\querying\Entity;
use type catarini\db\querying\EntityQuery;
use function catarini\db\type\__sql_val;
use function catarini\db\type\__sql_val_opt;

class tibble {

  public vec<string> $__sql_cols = vec[
    'id',
    'test',
  ];
  private ?int $id;
  private ?int $test;

  public function __construct(?int $id, ?int $test) {
    $this->id = $id;
    $this->test = $test;
  }

  public static function from_sql(dict<string, ?string> $row): tibble {
    $id = __sql_val_opt<int>(Type::INT, 'id', $row['id'], NULL);
    $test = __sql_val_opt<int>(Type::INT, 'test', $row['test'], NULL);
    return new tibble($id, $test);
  }
}
