<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<986fad26fec7ff2d9857c26314a18971>>
 */
namespace _catarini_test;
use namespace catarini\db;
use type catarini\db\Table;
use type catarini\db\Column;
use type catarini\db\Type;

function _db_schema(): db\Schema {
  return vec[

    new Table("tibble", vec[
      new Column(Type::INT, "test"),
    ]),

  ];
}
