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


    public function __construct(Table $reference, ReferenceAction $onUpdate, ReferenceAction $onDelete) { 
        $this->ref = $reference;
        $this->onUpdate = $onUpdate;
        $this->onDelete = $onDelete; 
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
    // All of these API functions only do onDelete... gotta make this very very very clear 

    public function nullify() : this { 
        $this->nullable = TRUE; 
        $this->onDelete = ReferenceAction::SET_NULL;
        return $this; 
    }

    //TODO: Default function
    // this will set the default, set both actions to SET_DEFAULT

    
    public function cascade() : this { 
        $this->onDelete = ReferenceAction::CASCADE;
        return $this;
    }

    public function restrict() : this { 
        $this->onDelete = ReferenceAction::RESTRICT;
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

    public function __construct(Table $table, Cardinality $cardinality = Cardinality::AGGREGATION, ?string $owned_attr = NULL, ?string $alias = NULL) { 
        $this->table        = $table;
        $this->cardinality  = $cardinality;
        $this->owned_attr   = $owned_attr; 
        $this->alias        = $alias;
    }

    public function getName() : string { return $this->alias ?? $this->table->getName(); }
}



class Relationship { 

    //TODO: string "id"?  constraint IDs?  

    protected Schema $schema;

    protected  RelationshipEnd $left;
    protected ?RelationshipEnd $right; 


    protected ?string $id; 


    //
    //
    //

    public function __construct(Schema $parent, RelationshipEnd $left, ?RelationshipEnd $right, ?string $id) { 
        $this->schema       = $parent;
        $this->left         = $left;
        $this->right        = $right;
        $this->id           = $id; 
    }


    // Initializers
    public static function API(Schema $parent, string $left_table_name, ?string $left_alias) : Relationship { 
        $tbl = $parent->getTable($left_table_name);
        // Arbitrary default - This should always be overriden by the "Finalizers" before inserting to the schema 
        // OR - be considered undefined and never used??? removed?? [Issue #39]
        $cardinality = Cardinality::OPTIONAL;

        return new Relationship($parent, new RelationshipEnd($tbl, $cardinality, $left_alias), NULL, NULL);
    }


    public function getID() : string { 
        return $this->id   ??   $this->left->getName().'_'.$this->getRight()->getName(); 
    }



    public function isIncomplete() : bool { return ($this->right is null); }

    // Accessors
    // By the time this object is inserted into the Schema, both left and right tables should always be initialized
    public function getLeft() :  RelationshipEnd { return not_null($this->left); }
    public function getRight() : RelationshipEnd { return not_null($this->right); }





    /**
     * Sets the right operand of this relationship, which is presumed to be the "owned" table - i.e. the one with the referencing foreign key - UNLESS an intermediate is given
     * [!] This function overwrites $this->left->cardinality, to either OPTIONAL or MANDATORY based on the nullability of the foreign key.
     *  (This behavior likely to be removed - see https://github.com/jacobconley/catarini/issues/39)
     * By default, $owned_attr will default to the name of a unique foreign key referencing the given table.  If no such key exists, an exception will be thrown.
     * @throws \catarini\exceptions\InvalidOperation If a suitable default cannot be found; see above 
     * @param $name Name of the table, which will be used to reference it within the parent `Schema`
     * @param $owned_attr The name of the foreign key in this (the right) table which references the left table.  See description for default behavior
     * @param $alias The name of the right side of the relationship from the perspective of the left.
     * @param $intermediate Intermediate table; which would override the right side as the "owned object", if that makes any goddamn sense at all 
     */
    protected function setRightTable(string $name, ?string $owned_attr, ?string $alias, ?Table $intermediate = NULL) : void { 
        $right = $this->schema->getTable($name); 

        $owned_obj = $intermediate ?? $right; // whew.  this fixed a potentially nasty bug.  probably still terrible program design though 
        $owned_col =   $owned_attr is nonnull ?  $owned_obj->getColumn($owned_attr)  :  $owned_obj->getColumnReferencing($this->getLeft()->table);
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

    public function through(string $intermediate) : RelationshipThrough { 
        return $this->schema->__relationship_through($this, $intermediate);
    }

    //
    // Finalizers
    //


    // "left-owned" relationships can always be generated automatically
    // so, for here,  since these are only called from API, assume right-owned 
    // therefore, left cardinality should be considered undefined?  or removed?? [Issue #39]

    public function hasOne(string $name, ?string $attr = NULL, ?string $alias = NULL) : void { 
        $this->setRightTable($name, $attr, $alias);
        $this->getRight()->cardinality  = Cardinality::MANDATORY;
    }

    public function hasOptional(string $name, ?string $attr = NULL, ?string $alias = Null) : void { 
        $this->setRightTable($name, $attr, $alias);
        $this->getRight()->cardinality  = Cardinality::OPTIONAL;
    }

    public function hasMany(string $name, ?string $attr = NULL, ?string $alias = Null) : void { 
        $this->setRightTable($name, $attr, $alias);
        $this->getRight()->cardinality = Cardinality::AGGREGATION;
    }

}


final class RelationshipThrough extends Relationship { 

    private Table $intermediate;
    public function getIntermediate() : Table { return $this->intermediate; }

    public function __construct(Schema $parent, RelationshipEnd $left, Table $intermediate, ?RelationshipEnd $right, ?string $id) { 
        parent::__construct($parent, $left, $right, $id); 
        $this->intermediate = $intermediate;
    }
    public static function JOIN(Relationship $r, Table $intermediate) : this { 
        return new RelationshipThrough($r->schema, $r->left, $intermediate, $r->right, NULL);
        // Passing along the ID causes an error as the right table is not set yet 
    }

    public function hasMany(string $name, ?string $attr = NULL, ?string $alias = NULL) : void { 
        $this->setRightTable($name, $attr, $alias, $this->intermediate);
        $this->getLeft()->cardinality   = Cardinality::HIDDEN; 
        $this->getRight()->cardinality  = Cardinality::AGGREGATION; 
    }

    public function manyToMany(string $name, ?string $attr = NULL, ?string $alias = NULL) : void { 
        $this->setRightTable($name, $attr, $alias, $this->intermediate);
        $this->getLeft()->cardinality   = Cardinality::AGGREGATION; 
        $this->getRight()->cardinality  = Cardinality::AGGREGATION; 
    }

    public function optionalToMany(string $name, ?string $attr = NULL, ?string $alias = NULL) : void { 
        $this->setRightTable($name, $attr, $alias, $this->intermediate);
        $this->getLeft()->cardinality   = Cardinality::OPTIONAL; 
        $this->getRight()->cardinality  = Cardinality::AGGREGATION; 
    }

    public function oneToMany(string $name, ?string $attr = NULL, ?string $alias = NULL) : void { 
        $this->setRightTable($name, $attr, $alias, $this->intermediate);
        $this->getLeft()->cardinality   = Cardinality::MANDATORY; 
        $this->getRight()->cardinality  = Cardinality::AGGREGATION; 
    }
}