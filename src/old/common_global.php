<?hh 

// PDO doesn't provide its own exception type 
class PDOSucksException extends RuntimeException
{
	public function __construct(PDOStatement $stmt)
	{
		parent::__construct($stmt->errorInfo());
	}
}
