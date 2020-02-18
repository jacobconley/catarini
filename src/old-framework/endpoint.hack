use simian\framework\BaseFramework;
use HH\ClassAttribute; 

class ENDPOINT 
{ 
	protected BaseFramework $FRAMEWORK;

	public function __construct(BaseFramework $FRAMEWORK) {
		$this->FRAMEWORK = $FRAMEWORK;
	}

	protected function RUN() : void { }
}

class HTTP_STATIC implements HH\ClassAttribute { 
    public function __construct(string... $routes) { 
    }
};
class HTTP_DYNAMIC implements HH\ClassAttribute { 
    public function __construct(HH\Lib\Regex\Pattern<string> $route) { 
    }
};
class HTTP_METHODS implements HH\ClassAttribute { 
    public function __construct(string... $methods) { 
    }
};