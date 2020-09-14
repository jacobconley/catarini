<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<0718a35c5c9ffc73f264762c8bf8eb80>>
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
      (new Reference($tables[0], 'tabble'))
      ->onDelete(ReferenceAction::CASCADE)->onUpdate(ReferenceAction::CASCADE)
    , FALSE))->nonnull(),
  ]);

  $relationships = vec[];

  return new Schema($tables, $relationships);
}
