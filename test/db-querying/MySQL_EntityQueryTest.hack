use catarini\db\backend\mysql;
use catarini\db\backend\mysql\EntityQuery; // [!!!!] 
use catarini\db\querying\{ Entity, EntityQueryTarget }; 

use catarini\db\Type; 
use catarini\db\schema\{ Column, Table, Reference, ReferenceAction, Cardinality, Relationship, RelationshipEnd };


use function Facebook\FBExpect\expect;
use function count; 

class MySQL_EntityQueryTest extends Facebook\HackTest\HackTest { 
    
    // lazy 
    private function TableQuery(Table $table) : EntityQuery<Entity> { 
        return new EntityQuery(new EntityQueryTarget($table));
    }


    //
    //
    // Unit Tests
    //
    //


    // Simple query


    public function testSimpleFetch() : void { 

        $q = $this->TableQuery(TestSchema::GET()->student);
        $q->__condition_pk(23);

        expect($q->__SELECT())  ->toBeSame("SELECT student.id, student.name, student.favorite_subject\n");
        expect($q->__FROM())    ->toBeSame("\nFROM student\n");
        expect($q->__WHERE())   ->toBeSame("\nWHERE student.id = %d\n");
    }


    //
    // Joining
    //


    public function testJoin() : void { 
        $tables = TestSchema::GET();
        $info = (new EntityQueryTarget($tables->teacher))
            ->join('id', $tables->class, 'teacher_id');
        $q = (new EntityQuery($info));

        expect($q->__SELECT())  ->toBeSame("SELECT class.id, class.subject, class.teacher_id\n");
        expect($q->__FROM())    ->toBeSame("\nFROM teacher\nJOIN class ON teacher.id = class.teacher_id\n");
    }



    public function testIntermediate() : void 
    { 
        $tables = TestSchema::GET();
        $q = (new EntityQueryTarget($tables->student))
            ->join_through($tables->student_class, 'student_id', 'class_id', $tables->class)
            |> new EntityQuery($$); 


        /*------*/
        $FROM = <<< SQL

FROM student
JOIN student_class ON student.id = student_class.student_id
JOIN class ON student_class.class_id = class.id

SQL;
        /*------*/

        expect($q->__FROM())->toBeSame($FROM); 
    }




//     //
//     //TODO: Test variable placeholders?  Conditions?  and such 
//     //



//     //
//     //
//     //
//     // Integration Tests
//     //
//     //
//     //

    public function testLinkedQuery() : void { 
        $tables = TestSchema::GET();

        $q1 =  (new EntityQueryTarget($tables->student))
            |> (new EntityQuery($$))
            -> __condition_pk(23); 

        $q2 = (new EntityQueryTarget($tables->student))
            ->join_through($tables->student_class, 'student_id', 'class_id', $tables->class)
            |> new EntityQuery($$, vec[ $q1 ]);

        $q  = (new EntityQueryTarget($tables->class))
            ->join('teacher_id', $tables->teacher, 'id')
            |> new EntityQuery($$, vec[ $q1, $q2 ]);
        
        $q->__condition_pk(23); 

        
        
        $FROM = <<< SQL

FROM student
JOIN student_class ON student.id = student_class.student_id
JOIN class ON student_class.class_id = class.id
JOIN teacher ON class.teacher_id = teacher.id

SQL;


        expect($q->__SELECT())  ->toBeSame("SELECT teacher.id, teacher.name\n");
        expect($q->__FROM())    ->toBeSame($FROM); 
        expect($q->__WHERE())   ->toBeSame("\nWHERE student.id = %d\nAND teacher.id = %d\n");
    }

}