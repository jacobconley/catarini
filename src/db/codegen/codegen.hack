namespace catarini\db\codegen;

use catarini\db\schema\{ Schema, Table }; 

class Codegen { 

    private ?string $namespace_public;
    private string  $namespace_private; 

    private string $dir_public, $dir_private; 

    public function getEntityNamespace() : ?string{ return $this->namespace_public; }
    public function getCodegenNamespace() : string { return $this->namespace_private; }

    
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


    private string $schema_fn = '_db_schema()';
    public function __schema_obj() : string { return "\\$this->namespace_private\\$this->schema_fn()"; }

    public function __table_obj(string $name) : string { 
        return "\\$this->namespace_private\\$this->schema_fn()->getTable('$name')";
    }


    public function getEntityBase(Table $table) : string { 
        $ns     = $this->namespace_private;
        $name   = $table->getEntityName();
        return "\\$ns\\$name"; 
    }
    public function getEntityUserland(Table $table) : string { 
        $ns     = "\\$this->namespace_public" ?? '';
        $name   = $table->getEntityName();
        return "$ns\\$name"; 
    }


    //
    //
    //

    public function genSchema(Schema $schema) : void { 
        schema\writeHack($this, $schema, $this->dir_private, $this->namespace_private);
    }

    public function genBaseEntities(Schema $schema) : void { 
        entities\write($this, $schema, $this->dir_public, $this->namespace_public, $this->dir_private, $this->namespace_private); 
    }

    // public function genUserlandEntities() : void { 
    // }


}