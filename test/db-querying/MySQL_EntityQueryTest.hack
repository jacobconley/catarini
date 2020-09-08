use catarini\db\backend\mysql;
use catarini\db\backend\mysql\EntityQuery; // [!!!!] 
use catarini\db\querying\{ Entity, EntityQueryTarget }; 

use catarini\db\Type; 
use catarini\db\schema\{ Column, Table };


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
        return new Table( 'parent', vec[ new Column(Type::STRING, 'name') ]);
    }
    private function tbl__student() : Table { 
        return new Table( 'student', vec[ new Column(Type::STRING, 'name'), new Column(Type::INT, 'parent_id') ]);
    }
    private function tbl__student_class() : Table { 
        return new Table( 'student_class', vec[ new Column(Type::INT, 'student_id'), new Column(Type::INT, 'class_id') ]);
    }
    private function tbl__class() : Table { 
        return new Table( 'class', vec[ new Column(Type::STRING, 'subject'), new Column(Type::INT, 'teacher_id') ]);
    }
    private function tbl__teacher() : Table { 
        return new Table('teacher', vec[ new Column(Type::STRING, 'name') ]); 
    }


    private function TableQuery(Table $table) : EntityQuery<Entity> { 
        return new EntityQuery(new EntityQueryTarget($table));
    }

    public function testPK() : void { 

        $q = $this->TableQuery($this->tbl__parent());
        $q->__condition_pk(23);

        expect($q->__FROM())    ->toBeSame("\nFROM parent\n");
        expect($q->__WHERE())   ->toBeSame("\nWHERE parent.parent_id = %d\n");

    }


    // Uh oh!  Somewhere, the "join id" probably isn't being set.  Was hastily migrated. 
    public function testJoin() : void { 
        // $info = (new EntityQueryTarget(tbl__parent))->join()
    }
}