use namespace Facebook\TypeAssert;
use namespace Facebook\TypeCoerce;

namespace catarini\db { 

    enum Type : int { 
        INT         = 0;
        NUMERIC     = 1;
        REAL        = 2; 

        STRING      = 10;
        TEXT        = 12;

        TIMESTAMP   = 20;
        DATETIME    = 21; 

        UUID        = 30; 
    }

    // Enum name as string.  Can we just do `$enum as string`  ?? 
    function typeToString(Type $type) : string { 
        switch($type) { 
            case Type::INT:         return "INT";
            case Type::NUMERIC:     return "NUMERIC";
            case Type::REAL:        return "REAL";
            case Type::STRING:      return "STRING";
            case Type::TEXT:        return "TEXT";
            case Type::TIMESTAMP:   return "TIMESTAMP";
            case Type::DATETIME:    return "DATETIME";
            case Type::UUID:        return "UUID";  
        }     
    }

    function typeStrval(Type $type, mixed $value) : string { 
        switch($type) { 
            case Type::INT:
            case Type::NUMERIC:
            case Type::REAL:
                return \strval($value); 

            case Type::STRING:
            case Type::TEXT:

            case Type::UUID:
            case Type::TIMESTAMP:
            case Type::DATETIME: 

                return '"'.TypeAssert\matches<string>($value).'"';

        }
    }

    function typeToHackType(Type $type) : string { 
        switch($type) { 
            case Type::INT:
                return 'int';

            case Type::NUMERIC:
            case Type::REAL:
                return 'float';

            case Type::STRING:
            case Type::TEXT:
                return 'string';

            case Type::UUID:
                return 'string';

            case Type::TIMESTAMP:
            case Type::DATETIME: 

                return "\\DateTime";
        }
    }

}

namespace catarini\db\type { 
    use catarini\db\Type; 
    use catarini\db\BadValueException;

    function to_string(Type $type) : string { 
        switch($type) { 
            case Type::INT:         return "INT";
            case Type::NUMERIC:     return "NUMERIC";
            case Type::REAL:        return "REAL";
            case Type::STRING:      return "STRING";
            case Type::TEXT:        return "TEXT";
            case Type::TIMESTAMP:   return "TIMESTAMP";
            case Type::DATETIME:    return "DATETIME";
            case Type::UUID:        return "UUID";  
        }     
    }

    function to_hack_literal(Type $type, mixed $value) : string {
        switch($type) { 
            case Type::INT:
            case Type::NUMERIC:
            case Type::REAL:
                return \strval($value); 

            case Type::STRING:
            case Type::TEXT:

            case Type::UUID:
            case Type::TIMESTAMP:
            case Type::DATETIME: 

                return '"'.TypeAssert\matches<string>($value).'"';

        }
    }


    function to_hack_type(Type $type) : string { 
        switch($type) { 
            case Type::INT:
                return 'int';

            case Type::NUMERIC:
            case Type::REAL:
                return 'float';

            case Type::STRING:
            case Type::TEXT:
                return 'string';

            case Type::UUID:
                return 'string';

            case Type::TIMESTAMP:
            case Type::DATETIME: 

                return "\\DateTime";
        }
    }



    function from_string<reify T>(Type $type, string $value) : T { 
        //TODO: Logic? 

        return TypeCoerce\match<T>($value); 
    }



    function __sql_val<reify T>(Type $type, string $colname, ?string $val, ?T $default) : T { 

        if($val is null) { 
            if($default is null) {
                throw new BadValueException("Value '$colname' should not be null"); 
            }
            else return $default; 
        }
        else return from_string<T>($type, $val); 

    }

    function __sql_val_opt<reify T>(Type $type, string $colname, ?string $val, ?T $default) : ?T { 

        if($val is null) { 
            if($default is nonnull) return $default; 
            else return NULL; 
        }
        else return from_string<T>($type, $val); 

    }

}