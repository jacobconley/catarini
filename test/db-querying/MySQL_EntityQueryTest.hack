use catarini\db\backend\mysql;
use catarini\db\querying\{ Entity, EntityQueryTarget, joinlist }; 

use catarini\db\Type; 
use catarini\db\schema\{ Column, Table, Reference, ReferenceAction, Cardinality, Relationship, RelationshipEnd };


use function Facebook\FBExpect\expect;
use function count; 






//
// Two VERY important definitions below for understanding the tests
//


use catarini\db\backend\mysql\EntityQuery; // NOT db\querying\EntityQuery !!!! 

// Dummy concrete EntityQuery
class EntityQuery_Test<Tm as Entity> extends mysql\EntityQuery<Tm> { 

    public function __construct(EntityQueryTarget $target, joinlist $prev = vec[]) { 
        parent::__construct(NULL, $target, $prev); 
    }

    private function throw() : noreturn { throw new \Exception("This is a dummy class; these methods are not implemented"); }

    protected function from_row(Map<string, ?string> $row) : Tm { $this->throw(); }
    public function first() : Awaitable<Tm> { $this->throw(); }
}






class MySQL_EntityQueryTest extends Facebook\HackTest\HackTest { 
    
    // lazy 
    private function TableQuery(Table $table) : EntityQuery<Entity> { 
        return new EntityQuery_Test(new EntityQueryTarget($table));
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
        $q = (new EntityQuery_Test($info));

        expect($q->__SELECT())  ->toBeSame("SELECT class.id, class.subject, class.teacher_id\n");
        expect($q->__FROM())    ->toBeSame("\nFROM teacher\nJOIN class ON teacher.id = class.teacher_id\n");
    }



    public function testIntermediate() : void 
    { 
        $tables = TestSchema::GET();
        $q = (new EntityQueryTarget($tables->student))
            ->join_through($tables->student_class, 'student_id', 'class_id', $tables->class)
            |> new EntityQuery_Test($$); 


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
            |> (new EntityQuery_Test($$))
            -> __condition_pk(23); 

        $q2 = (new EntityQueryTarget($tables->student))
            ->join_through($tables->student_class, 'student_id', 'class_id', $tables->class)
            |> new EntityQuery_Test($$, vec[ $q1 ]);

        $q  = (new EntityQueryTarget($tables->class))
            ->join('teacher_id', $tables->teacher, 'id')
            |> new EntityQuery_Test($$, vec[ $q1, $q2 ]);
        
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