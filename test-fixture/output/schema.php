<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<0b238d94e1820196b76b7e3e9ec23991>>
 */
namespace _catarini_test;
use namespace catarini\db;
use type catarini\db\Type;
use type catarini\db\schema\{ Table, Column, Schema, Reference, ReferenceAction, Relationship, RelationshipEnd, Cardinality };

function _db_schema(): Schema {
  $tables = vec[];

  $tables[] = new Table("tibble", vec[
    (new Column(Type::INT, "id", NULL, TRUE))->nonnull()->unique(),
    (new Column(Type::INT, "test", NULL, FALSE)),
  ]);

  $tables[] = new Table("other", vec[
    (new Column(Type::INT, "id", NULL, TRUE))->nonnull()->unique(),
    (new Column(Type::INT, "tibble_id", 
      (new Reference($tables[0], ReferenceAction::CASCADE, ReferenceAction::RESTRICT))
    , FALSE))->nonnull(),
  ]);

  $relationships = vec[];

  return new Schema($tables, $relationships);
}
