namespace catarini\db\schema;

use function Facebook\TypeAssert\not_null;


enum ReferenceAction : string { 
    SET_NULL    = 'SET_NULL';
    SET_DEFAULT = 'SET_DEFAULT'; 
    CASCADE     = 'CASCADE';
    RESTRICT    = 'RESTRICT'; 
}


final class Reference { 

    private Table $ref; 
    public function getReferencedTable() : Table { return $this->ref; }

    private ?string $alias; 
    public function getAlias() : ?string { return $this->alias; }

    public function __construct(Table $reference, ?string $alias) { 
        $this->ref = $reference;
        $this->alias = $alias; 
    }



    private ReferenceAction $onDelete = ReferenceAction::CASCADE;
    private ReferenceAction $onUpdate = ReferenceAction::CASCADE;
    private bool $nullable = FALSE; 

    public function getDeleteAction() : ReferenceAction { return $this->onDelete; }
    public function getUpdateAction() : ReferenceAction { return $this->onUpdate; }
    public function isNullable() : bool { return $this->nullable; }


    //
    // API functions
    //


    public function onDelete(ReferenceAction $action) : this { $this->onDelete = $action; return $this; }
    public function onUpdate(ReferenceAction $action) : this { $this->onUpdate = $action; return $this; }

    public function nullable() : this { $this->nullable = TRUE; return $this; }


    // ReferenceActions

    public function nullify() : this { 
        $this->nullable = TRUE; 
        $this->onDelete = ReferenceAction::SET_NULL;
        $this->onUpdate = ReferenceAction::SET_NULL;
        return $this; 
    }

    //TODO: Default function
    // this will set the default, set both actions to SET_DEFAULT

    
    public function cascade() : this { 
        $this->onDelete = ReferenceAction::CASCADE;
        $this->onUpdate = ReferenceAction::CASCADE;
        return $this;
    }

    public function restrict() : this { 
        $this->onDelete = ReferenceAction::RESTRICT;
        $this->onUpdate = ReferenceAction::RESTRICT;
        return $this;
    }

}


enum Cardinality : string { 
    OPTIONAL    = 'OPTIONAL';
    MANDATORY   = 'MANDATORY';
    AGGREGATION = 'AGGREGATION'; 
    HIDDEN      = 'HIDDEN';
}

final class RelationshipEnd { 
    public Table $table; 
    public Cardinality $cardinality;

    private ?string $owned_attr;
    private ?string $alias; 

    public function __construct(Table $table, Cardinality $cardinality, ?string $owned_attr = NULL, ?string $alias = NULL) { 
        $this->table        = $table;
        $this->cardinality  = $cardinality;
        $this->owned_attr   = $owned_attr; 
        $this->alias        = $alias;
    }

    public function getName() : string { return $this->alias ?? $this->table->getName(); }
}

final class Relationship { 

    //TODO: string "id"?  constraint IDs?  

    private Schema $schema;

    private  RelationshipEnd $left;
    private ?RelationshipEnd $right; 
    private ?Table $intermediate;


    private ?string $id; 

    public function __construct(Schema $parent, RelationshipEnd $left, ?RelationshipEnd $right, ?string $id) { 
        $this->schema       = $parent;
        $this->left         = $left;
        $this->right        = $right;
        $this->id           = $id; 
    }


    // Initializers
    public static function API(Schema $parent, string $left_table_name, ?string $left_alias) : this { 
        $tbl = $parent->getTable($left_table_name);
        // Arbitrary default - This should always be overriden by the "Finalizers" before inserting to the schema 
        $cardinality = Cardinality::OPTIONAL;

        return new Relationship($parent, new RelationshipEnd($tbl, $cardinality, $left_alias), NULL, NULL);
    }



    public function getIntermediate() : ?Table { return $this->intermediate; }

    public function getID() : string { 
        return $this->id   ??   $this->left->getName().'_'.$this->getRight()->getName(); 
    }

    // Accessors
    // By the time this object is inserted into the Schema, both left and right tables should always be initialized
    public function getLeft() :  RelationshipEnd { return not_null($this->left); }
    public function getRight() : RelationshipEnd { return not_null($this->right); }







    // for now, presume this is the owned table 
    /**
     * Sets the right operand of this relationship, which is presumed to be the "owned" table - i.e. the one with the referencing foreign key. 
     * [!] This function overwrites $this->left->cardinality, to either OPTIONAL or MANDATORY based on the nullability of the foreign key.
     * By default, $owned_attr will default to the name of a unique foreign key referencing the given table.  If no such key exists, an exception will be thrown.
     * @throws InvalidOperation If a suitable default cannot be found; see above 
     * @param $name Name of the table, which will be used to reference it within the parent `Schema`
     * @param $owned_attr The name of the foreign key in this (the right) table which references the left table.  See description for default behavior
     * @param $alias The name of the right side of the relationship from the perspective of the left.
     */
    private function setRightTable(string $name, ?string $owned_attr, ?string $alias) : void { 
        $right = $this->schema->getTable($name); 

        $owned_col =   $owned_attr is nonnull ?  $right->getColumn($owned_attr)  :  $right->getColumnReferencing($right);
        if($owned_col is null) throw new \catarini\exceptions\InvalidOperation("Could not determine an unambigous reference attribute"); // TODO: Less shitty error message
        $owned_attr = $owned_col->getName();

        $this->right = new RelationshipEnd($right, Cardinality::OPTIONAL, $owned_attr, $alias);

        $this->left->cardinality =   $owned_col->isNullable()  ?  Cardinality::OPTIONAL  :  Cardinality::MANDATORY;
    }


    



    //
    //
    // API Functions
    //
    //

    public function nonmutual() : this { $this->left->cardinality = Cardinality::HIDDEN;  return $this; }



    //
    // Finalizers
    //


    // "left-owned" relationships can always be generated automatically
    // so, for here,  since these are only called from API, assume right-owned 

    public function hasOne(string $name, ?string $attr = NULL, ?string $alias = NULL) : this { 
        $this->setRightTable($name, $attr, $alias);
        $this->getRight()->cardinality  = Cardinality::MANDATORY;
        return $this; 
    }

    public function mayHaveOne(string $name, ?string $attr = NULL, ?string $alias = Null) : this { 
        $this->setRightTable($name, $attr, $alias);
        $this->getRight()->cardinality  = Cardinality::OPTIONAL;
        return $this; 
    }

    public function hasMany(string $name, ?string $attr = NULL, ?string $alias = Null) : this { 
        $this->setRightTable($name, $attr, $alias);
        $this->getRight()->cardinality = Cardinality::AGGREGATION;
        return $this; 
    }

    public function hasManyThrough(string $intermediate, string $name, ?string $attr = NULL, ?string $alias = NULL) : this { 
        $this->setRightTable($name, $attr, $alias);
        $this->getRight()->cardinality = Cardinality::AGGREGATION;
        $this->intermediate = $this->schema->getTable($intermediate); 
        return $this; 
    }

    public function manyToManyThrough(string $intermediate, string $name, ?string $attr = NULL, ?string $alias = NULL) : this { 
        $this->setRightTable($name, $attr, $alias);
        $this->getLeft()->cardinality   = Cardinality::AGGREGATION; 
        $this->getRight()->cardinality  = Cardinality::AGGREGATION;
        $this->intermediate = $this->schema->getTable($intermediate); 
        return $this; 
    }
}