<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<822c213063beb6ff646cf5d7c2128d2d>>
 */
namespace _catarini_test;
use namespace catarini\db;
use type catarini\db\Type;
use type catarini\db\schema\{ Table, Column, Schema };

function _db_schema(): Schema {

  $tables = vec[

    new Table("tibble", vec[
      new Column(Type::INT, "id"),
      new Column(Type::INT, "test"),
    ], "id"),

  ];

  $relationships = vec[
  ];

  return new Schema($tables, $relationships);
}
