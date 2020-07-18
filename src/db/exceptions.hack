namespace catarini\db; 

class DBException extends \catarini\Exception {

}


// No such record
class NotFoundException extends DBException { 

    public function __construct(?string $message = NULL) { 
        parent::__construct($message ?? "No such record exists", 404); 
    }

}



class BadValueException extends DBException { 

    public function __construct(?string $message = NULL) { 
        parent::__construct($message ?? "Invalid value", 422);
    }
    
}

class DuplicateValueException extends BadValueException { 

}



class BadRequestException extends DBException { 
    public function __construct() { 
        parent::__construct("Bad request", 400);
    }
}

