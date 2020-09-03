namespace catarini\db\schema;

use catarini\db\Type as dbType; 
use namespace catarini\db\type;

use HH\Lib\Vec; 

use namespace Facebook\TypeAssert;
use namespace Facebook\TypeCoerce;
use Facebook\HackCodegen\{ IHackBuilderValueRenderer, IHackCodegenConfig };


class Column 
{ 
    protected string $name;
    protected dbType $type;
    public function __construct(dbType $type, string $name) { 
        $this->name = $name;
        $this->type = $type; 
    }


    protected   bool         $nullable           = TRUE; 
    protected   bool         $unique             = FALSE; 
    protected  ?string       $condition; 

    private     bool         $hasDefault         = FALSE;
    protected   mixed        $default; 

    public function getName() : string { return $this->name; }
    public function getType() : dbType { return $this->type; }

    public function isNullable() : bool { return $this->nullable; }
    public function isUnique() : bool { return $this->unique; }

    public function hasDefault() : bool { return $this->hasDefault; }



    //
    // Rendering code
    //
    
    /* Idk this shit has to be organized
        But all of this is used by l'Entity Output 
     */


    public function _str_default() : ?string { 
        if(! $this->hasDefault()) return null; 
        $def = $this->default; 
        return $def is null ? 'null' : type\to_hack_literal($this->type, $def); 
    }

    public function _str_condition() : ?string { 
        $x = $this->condition;
        return $x ? "$x" : null; 
    }

    public function _str_HackType() : string { 
        $type = type\to_hack_type($this->type); 
        return  $this->isNullable() ? "?$type" : $type; 
    }


    public function __column_renderer() : __column_renderer { 
        return new __column_renderer();
    }


    /**
     * veeeery unsafe way to generate type conversions 
     */
    public function __sql_val_call(string $operand) : string { 
        $fn_name = $this->isNullable() ? '__sql_val_opt' : '__sql_val'; 
        $type_hack = type\to_hack_type($this->getType());

        $type_enum = type\to_enum($this->getType());
        $type_enum = "Type::$type_enum"; 

        $colname = $this->getName(); 

        //TODO: Support defaults here
        //TODO: How defaults will be entered?  as type-safe?  idfk man
        return "$fn_name<$type_hack>($type_enum, '$colname', $operand, NULL)";
    }

    
    //
    // API 
    //

    public function nonnull() : this { $this->nullable = FALSE; return $this; }
    public function unique() : this { $this->unique = TRUE; return $this; }

    public function default(mixed $def) : this { 
        $this->hasDefault = TRUE; 
        $this->default = $def; 
        return $this; 
    }

    //TODO:  Generalize these

    public function check(string $condition) : this { 
        $this->condition = $condition;
        return $this; 
    }

    //
    // Core
    // 

    /**
     * This should be called before any render
     * ?????????/
     */ 
    protected function validate() : void { 
        if(!($this->nullable) && $this->hasDefault && $this->default is null) throw new \LogicException("Non-nullable column has null default"); 
    }



}



// Unsafe renderer
class __column_renderer implements IHackBuilderValueRenderer<string> { 
    public function render(IHackCodegenConfig $config, string $input) : string { return $input; }
}