namespace catarini\db\codegen;

use catarini\db\schema\{ Schema, Table }; 

class Codegen { 

    private ?string $namespace_public;
    private string  $namespace_private; 

    private string $dir_public, $dir_private; 

    public function getPublicNamespace() : ?string{ return $this->namespace_public; }
    public function getPrivateNamespace() : string { return $this->namespace_private; }

    
    // Convention set here:  public namespace, public dir, priv namespace, priv dir 

    public function __construct( ?string $name, 
                                 ?string $namespace, 
                                 string $public_dir, 
                                 ?string $pvt_namespace, 
                                 string $pvt_dir ) 
    { 
        $this->namespace_public = $namespace;   
        $this->namespace_private = $pvt_namespace ?? ("__cdbcg_".( $name ?? '' ));

        $this->dir_public = $public_dir;
        $this->dir_private = $pvt_dir; 
    }


    private string $schema_fn = '_db_schema';
    public function __schema_obj() : string { return "\\$this->namespace_private\\$this->schema_fn()"; }

    public function __table_obj(string $name) : string { 
        return "\\$this->namespace_private\\$this->schema_fn()->getTable('$name')";
    }




    public function getEntityBaseNamespace() : string { return "$this->namespace_private\\entity"; }
    public function getEntityQueryNamespace() : string { return "$this->namespace_private\\query"; }
    public function getEntityUserlandNamespace() : string { return ($this->namespace_public ?? ''); }



    public function getEntityBase(Table $table) : string { 
        return $this->getEntityBaseNamespace()."\\".$table->getEntityName();
    }
    public function getEntityUserland(Table $table) : string { 
        return $this->getEntityUserlandNamespace()."\\".$table->getEntityName();
    }


    public function getEntityQueryName(Table $table) : string { 
        return "Query_".$table->getEntityName();
    }
    public function getEntityQuery(Table $table) : string { 
        return $this->getEntityQueryNamespace().'\\'.$this->getEntityQueryName($table);
    }


    //
    //
    //

    public function genSchema(Schema $schema) : void { 
        schema\writeHack($this, $schema, $this->dir_private, $this->namespace_private);
    }

    public function genEntities(Schema $schema) : void { 
        entities\writeAll($this, $schema, $this->dir_public, $this->namespace_public, $this->dir_private, $this->namespace_private); 
    }

    // public function genUserlandEntities() : void { 
    // }


}