use catarini\db\backend\mysql;
use catarini\db\backend\mysql\EntityQuery; // [!!!!] 
use catarini\db\querying\{ Entity, EntityQueryTarget }; 

use catarini\db\Type; 
use catarini\db\schema\{ Column, Table, Reference, ReferenceAction, Cardinality, Relationship, RelationshipEnd };


use function Facebook\FBExpect\expect;
use function count; 

class MySQL_EntityQueryTest extends Facebook\HackTest\HackTest { 
    

    //
    // Schema A
    //

    /*

        belongs_to - "references" better?  

        parent -|---|<- student -|---|- student_class -|---|-   class ->|------------|- teacher
                    belongs_to parent   join table              belongs_to teacher      
                    has_mutual class    belongs to each         has_mutual student      has_many class

    */


    private function tbl__parent() : Table { 
        return new Table( 'parent', vec[ 
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'name') 
        ]);
    }
    private function tbl__student() : Table { 
        return new Table( 'student', vec[ 
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'name'), 
            new Column(Type::INT, 'parent_id') 
        ]);
    }
    private function tbl__student_class() : Table { 
        return new Table( 'student_class', vec[ 
            new Column(Type::INT, 'student_id',  
                new Reference($this->tbl__student(), ReferenceAction::CASCADE, ReferenceAction::CASCADE)
            , TRUE), 
            new Column(Type::INT, 'class_id',   
                new Reference($this->tbl__class(),  ReferenceAction::CASCADE, ReferenceAction::CASCADE)
            , TRUE), 
        ]);
    }
    private function tbl__class() : Table { 
        return new Table( 'class', vec[ 
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'subject'), 
            new Column(Type::INT, 'teacher_id') 
        ]);
    }
    private function tbl__teacher() : Table { 
        return new Table('teacher', vec[ 
            new Column(Type::INT, 'id', NULL, TRUE),
            new Column(Type::STRING, 'name') 
        ]); 
    }


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

        $q = $this->TableQuery($this->tbl__parent());
        $q->__condition_pk(23);

        expect($q->__SELECT())  ->toBeSame("SELECT parent.id, parent.name\n");
        expect($q->__FROM())    ->toBeSame("\nFROM parent\n");
        expect($q->__WHERE())   ->toBeSame("\nWHERE parent.id = %d\n");
    }


    //
    // Joining
    //


    public function testJoin() : void { 
        $info = (new EntityQueryTarget($this->tbl__parent()))
            ->join('id', $this->tbl__student(), 'parent_id');
        $q = (new EntityQuery($info));

        expect($q->__SELECT())  ->toBeSame("SELECT student.id, student.name, student.parent_id\n");
        expect($q->__FROM())    ->toBeSame("\nFROM parent\nJOIN student ON parent.id = student.parent_id\n");
    }



    public function testIntermediate() : void 
    { 
        $q = (new EntityQueryTarget($this->tbl__student()))
            ->join_through($this->tbl__student_class(), 'student_id', 'class_id', $this->tbl__class())
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




    //
    //TODO: Test variable placeholders?  Conditions?  and such 
    //



    //
    //
    //
    // Integration Tests
    //
    //
    //

    public function testLinkedQuery() : void { 

        $q1 =  (new EntityQueryTarget($this->tbl__parent()))
            |> (new EntityQuery($$))
            -> __condition_pk(23); 

        $q2 = (new EntityQueryTarget($this->tbl__parent()))
            ->join('id', $this->tbl__student(), 'parent_id')
            |> new EntityQuery($$); 

        $q  = (new EntityQueryTarget($this->tbl__student()))
            ->join_through($this->tbl__student_class(), 'student_id', 'class_id', $this->tbl__class())
            |> new EntityQuery($$, vec[$q1, $q2]);
        
        $q->__condition_pk(23); 

        
        
        $FROM = <<< SQL

FROM parent
JOIN student ON parent.id = student.parent_id
JOIN student_class ON student.id = student_class.student_id
JOIN class ON student_class.class_id = class.id

SQL;


        expect($q->__SELECT())  ->toBeSame("SELECT class.id, class.subject, class.teacher_id\n");
        expect($q->__FROM())    ->toBeSame($FROM); 
        expect($q->__WHERE())   ->toBeSame("\nWHERE parent.id = %d\nAND class.id = %d\n");

    }

}