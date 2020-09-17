use catarini\db\backend\mysql;
use catarini\db\backend\mysql\EntityQuery; // [!!!!] 
use catarini\db\querying\{ Entity, EntityQueryTarget }; 

use catarini\db\Type; 
use catarini\db\schema\{ Schema, Column, Table, Reference, ReferenceAction, Cardinality, Relationship, RelationshipThrough, RelationshipEnd };


use function Facebook\FBExpect\expect;
use function count; 


/**
 * [TEST] A nice schema with references and relationships, used to test the Schema API and codegen
 */
final class TestSchema { 

    public Table $student, $teacher, $subject, $class, $student_class;

    public vec<Table>           $tables; 
    public vec<Relationship>    $relationships;

    public Schema               $schema; 

    public function __construct() { 

        $this->teacher = new Table('teacher', vec[ 
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'name') 
        ]); 

        $this->subject = new Table('subject', vec[
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'name'),
        ]);

        $this->class = new Table( 'class', vec[ 
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'subject',
                new Reference($this->subject, ReferenceAction::CASCADE, ReferenceAction::RESTRICT)
            , FALSE), 
            new Column(Type::INT, 'teacher_id',
                new Reference($this->teacher, ReferenceAction::CASCADE, ReferenceAction::RESTRICT),
            FALSE),
        ]);

        $this->student = new Table( 'student', vec[ 
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'name'), 
            new Column(Type::INT, 'favorite_subject', new Reference($this->subject, ReferenceAction::CASCADE, ReferenceAction::SET_NULL)),
        ]);


        $this->student_class = new Table( 'student_class', vec[ 
            new Column(Type::INT, 'student_id',  
                new Reference($this->student, ReferenceAction::CASCADE, ReferenceAction::CASCADE)
            , TRUE), 
            new Column(Type::INT, 'class_id',   
                new Reference($this->class,  ReferenceAction::CASCADE, ReferenceAction::CASCADE)
            , TRUE), 
        ]);

        // Must be in this order because of references
        // I wonder if that sucks shit or not 
        // Can probably fix it in codegen if it does        [Issue #41]
        $this->tables = vec[ $this->teacher, $this->subject, $this->class, $this->student, $this->student_class ];

        $this->schema = new Schema($this->tables);
        $this->relationships = vec[]; 

        // student_class
        $this->relationships[] = new RelationshipThrough($this->schema, 
            new RelationshipEnd($this->student, Cardinality::AGGREGATION, 'student_id'),
            $this->student_class,
            new RelationshipEnd($this->class, Cardinality::AGGREGATION, 'class_id'),
            'student_class'
        );

        // teacher_class
        $this->relationships[] = new Relationship($this->schema, 
            new RelationshipEnd($this->teacher, Cardinality::MANDATORY),
            new RelationshipEnd($this->class, Cardinality::AGGREGATION, 'teacher_id'),
            'teacher_class'
        );

        // students_favorited
        $this->relationships[] = new Relationship($this->schema,
            new RelationshipEnd($this->subject, Cardinality::HIDDEN),
            new RelationshipEnd($this->student, Cardinality::AGGREGATION, 'students_favorited'),
            'students_favorited'
        );


        $this->schema->setRelationships($this->relationships); 
    }

    <<__Memoize>>
    public static function GET() : this { 
        return new TestSchema();
    }


    

    /*

        belongs_to - "references" better?  

        student -|---|- student_class -|---|-   class ->|------------|- teacher
        ^                                        ^
        -|---------------------- subject |-------|   

    */

}