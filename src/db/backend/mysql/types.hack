namespace catarini\db\backend\mysql;

use catarini\db\Type; 

use Facebook\{ TypeAssert, TypeCoerce }; 
use DateTime;

function type_sql_literal(Type $type, mixed $value) : string { 

    if($value is null) return 'NULL';

    switch($type) { 
            case Type::INT:
            case Type::NUMERIC:
            case Type::REAL:
                return \strval($value); 

            case Type::STRING:
            case Type::TEXT:
            case Type::UUID:
                return '"'.TypeAssert\matches<string>($value).'"';

            case Type::TIMESTAMP:
            case Type::DATETIME: 
                $date = TypeAssert\matches<DateTime>($value); 
                return \strval($date); // Uhhhh, this right? 

    }
}

/**
 * Type holder corresponding to HHVM docs 
 * @see https://docs.hhvm.com/hack/reference/class/AsyncMysqlConnection/queryf/ 
 */
function type_sql_placeholder(Type $type) : string { 
    switch($type) { 
            case Type::INT:
                return '%d';

            case Type::NUMERIC:
            case Type::REAL:
                return '%f';

            case Type::STRING:
            case Type::TEXT:
            case Type::UUID:
            case Type::TIMESTAMP:
            case Type::DATETIME: 
                return '%s';

    }
}