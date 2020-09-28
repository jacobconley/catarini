namespace catarini\db;

// This is the main API 
// uuuuhhh

interface Database { 


    public function addTable(string $name, schema\TableCreatorBlock $block) : this;

    public function changeTable(string $name, schema\TableChangerBlock $block) : this; 

    public function delTable(string $name) : this; 


    //TODO: Rename 

}
