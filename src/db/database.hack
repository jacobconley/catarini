namespace catarini\db;

// This is the main API 
// uuuuhhh

interface Database { 


    public function addTable(string $name, TableCreatorBlock $block) : this;

    public function changeTable(string $name, TableChangerBlock $block) : this; 

    public function delTable(string $name) : this; 

    //TODO: Rename 

}
