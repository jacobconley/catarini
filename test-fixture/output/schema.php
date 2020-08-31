<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<53fa79a74215301e41c6cc21aac56c0d>>
 */
namespace _catarini_test;
use namespace catarini\db;
use type catarini\db\Type;
use type catarini\db\schema\{ Table, Column, Schema };

function _db_schema(): Schema {
  return vec[

    new Table("tibble", vec[
      new Column(Type::INT, "test"),
    ]),

  ];
}
