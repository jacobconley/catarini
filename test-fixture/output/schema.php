<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<03e0f1c5865b5fdcd712ade797a0ab69>>
 */
namespace _catarini_test;
use namespace catarini\db;
use type catarini\db\Type;
use type catarini\db\schema\{ Table, Column, Schema, Reference, ReferenceAction, Relationship, RelationshipEnd, RelationshipThrough, Cardinality };

function _db_schema(): Schema {
  $tables = vec[];

  $tables[] = new Table("teacher", vec[
    (new Column(Type::INT, "id", NULL, TRUE)),
    (new Column(Type::STRING, "name", NULL, FALSE)),
  ]);

  $tables[] = new Table("subject", vec[
    (new Column(Type::INT, "id", NULL, TRUE)),
    (new Column(Type::STRING, "name", NULL, FALSE)),
  ]);

  $tables[] = new Table("class", vec[
    (new Column(Type::INT, "id", NULL, TRUE)),
    (new Column(Type::STRING, "subject", 
      (new Reference($tables[1], ReferenceAction::CASCADE, ReferenceAction::RESTRICT))
    , FALSE)),
    (new Column(Type::INT, "teacher_id", 
      (new Reference($tables[0], ReferenceAction::CASCADE, ReferenceAction::RESTRICT))
    , FALSE)),
  ]);

  $tables[] = new Table("student", vec[
    (new Column(Type::INT, "id", NULL, TRUE)),
    (new Column(Type::STRING, "name", NULL, FALSE)),
    (new Column(Type::INT, "favorite_subject", 
      (new Reference($tables[1], ReferenceAction::CASCADE, ReferenceAction::SET_NULL))
    , FALSE)),
  ]);

  $tables[] = new Table("student_class", vec[
    (new Column(Type::INT, "student_id", 
      (new Reference($tables[3], ReferenceAction::CASCADE, ReferenceAction::CASCADE))
    , TRUE)),
    (new Column(Type::INT, "class_id", 
      (new Reference($tables[2], ReferenceAction::CASCADE, ReferenceAction::CASCADE))
    , TRUE)),
  ]);


  $schema = new Schema($tables);
  $relationships = vec[];

  $relationships[] = new RelationshipThrough($schema,
    new RelationshipEnd($tables[3], Cardinality::AGGREGATION, 'student'),
    $tables[4],
    new RelationshipEnd($tables[2], Cardinality::AGGREGATION, 'class'),
    'student_class'
  );
  $relationships[] = new Relationship($schema,
    new RelationshipEnd($tables[0], Cardinality::MANDATORY, 'teacher'),
    new RelationshipEnd($tables[2], Cardinality::AGGREGATION, 'class'),
    'teacher_class'
  );
  $relationships[] = new Relationship($schema,
    new RelationshipEnd($tables[1], Cardinality::HIDDEN, 'subject'),
    new RelationshipEnd($tables[3], Cardinality::AGGREGATION, 'student'),
    'students_favorited'
  );


  $schema->setRelationships($relationships);
  return $schema;
}
