
use namespace Facebook\{ TypeAssert, TypeCoerce }; 
use HH\Lib\{ Vec, Str }; 

class _CatariniXHP { 

	private Catarini $C;
	public function __construct(Catarini $c) { 
		$this->C = $c; 
	}

	private vec<XHPRoot> $head = vec[]; 
	private vec<XHPRoot> $body = vec[]; 

	public function append(mixed $el) : _CatariniXHP { 

		if($el is XHPRoot) { 
			$this->body[] = $el; 
		} else { 
			$arry = TypeCoerce\match<vec<XHPRoot>>($el); 
			$this->body = Vec\concat($this->body, $arry); 
		}

		return $this; 
	}


	private ?string $Title; 
	public function getTitle() : ?string { return $this->Title; }
	public function setTitle(string $title) : void { $this->Title = $title; }


	// Assets

	public function include(string $url) : _CatariniXHP { 

		if(Str\ends_with_ci($url, '.js')) { 
			$this->head[] = <script type="text/javascript" src={$url} ></script>; 
		}
		else if(Str\ends_with_ci($url, '.css')) { 
			$this->head[] = <link rel="stylesheet" type="text/css" href={$url} />;
		}
		else throw new catarini\exception\Exception("Unrecognized file type passed to ->include()");

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

	private function renderBody() : XHPRoot { 
		return <body>{ $this->body }</body>;
	}

	public function render() : void { 
		echo <html>
			{ $this->renderHead() }
			{ $this->renderBody() }
		</html>;
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
