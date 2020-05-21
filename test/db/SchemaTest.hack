use catarini\db\{ Database, table_creator }; 

class SchemaTest extends Facebook\HackTest\HackTest { 

    private function db() : Database { 
        catarini\meta\CONFIG::_forceRoot(dirname(__FILE__)."/env/");
        return Catarini::GET()->db(); 
    }

    // public function testCreate() : void { 
    //     $DB = $this->db(); 
    //     $DB->addTable('test', $x ==> {}); 
    // }


    // 
    // TableCreator tests
    // 

    public function testTableCreator() : void 
    { 
        // $t = new TableCreator();  
        // $t->add('testint')->int()->nonnull(); 



    }
}