
use namespace Facebook\{ TypeAssert, TypeCoerce }; 
use HH\Lib\{ Vec, Str }; 

class _CatariniXHP { 

	private Catarini $C;
	public function __construct(Catarini $c) { 
		$this->C = $c; 
	}

	private vec<XHPRoot> $head = vec[]; 


	private ?string $Title; 
	public function getTitle() : ?string { return $this->Title; }
	public function setTitle(string $title) : void { $this->Title = $title; }


	// Assets

	// Maybe this shite should be in the main framework object?
	//  Well, no, within the body of a document the main object should be $C->html() anyways 

	public function include(string $url) : _CatariniXHP { 

		if(Str\ends_with_ci($url, '.js')) { 
			$this->head[] = <script type="text/javascript" src={$url} ></script>; 
		}
		else if(Str\ends_with_ci($url, '.css')) { 
			$this->head[] = <link rel="stylesheet" type="text/css" href={$url} />;
		}
		else throw new catarini\Exception("Unrecognized file type passed to ->include()");

		return $this; 
	}

	// public function compile(string $url) : void { 
		
	// }



	//
	// Rendering
	//


	private function renderHead() : XHPRoot { 
		$head = <head>{ $this->head }</head>; 

		if($this->Title) $head->appendChild(<title>{$this->Title}</title>); 

		return $head; 
	}

	public function render(?XHPRoot $content = NULL) : noreturn 
	{ 
		echo <html>
			{ $this->renderHead() }
			<body>{ $content }</body>
		</html>;
		\exit(0); 
	}



	public function render_error(int $status) : noreturn { 
		\http_response_code($status); 
		$this->render( $this->C->errors()->_invoke_xhp($status) );
	}
	public function render_exception(\Exception $ex) : noreturn { 
		$status = 500;
		$cex = $ex ?as \catarini\Exception; 
		if($cex) $status = $cex->getHttpStatus(); 
		$this->render_error($status);
	}

	public function render_lambda((function() : XHPRoot) $lambda) : noreturn { 
		try { 
			$this->render($lambda()); 
		}
		catch (\Exception $ex) { $this->render_exception($ex); }
		\exit(0); 
	}


	//
	//
	//


	// Default error page here
	// Gotta style this stuff
    public static function http_error(int $status) : XHPRoot { 
        return <h1>HTTP ERROR {$status}</h1>; 
    }

}
