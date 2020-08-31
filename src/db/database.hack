namespace catarini\db;

// This is the main API 
// uuuuhhh

interface Database { 


    public function addTable(string $name, schema\TableCreatorBlock $block) : this;

    public function changeTable(string $name, schema\TableChangerBlock $block) : this; 

    public function delTable(string $name) : this; 


    /**
     * Get a writer for the schema currently represented by this database; 
     */ 
     //TODO:  Do we even need this in the database?  I mean shit 
    public function getSchemaWriter(string $dir) : migration\SchemaWriter;

    //TODO: Rename 

}
