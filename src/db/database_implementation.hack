namespace catarini\db;

interface DatabaseInstance extends Database { 

    //TODO: Define query hooks here that Query<T> can use
    // the last parts of the query; i.e. the ->first(), ->each($x ==> ...), etc
    //
    // Q: Type safety for these - make these generic with respect to the Model type?
    // That could be consistent with the approach I've made thus far 

    // not sure why, but if i make this return Awaitable<Tm>, downstream functions will try to return 
    //  Awaitable<Awaitable<Tm>>, at least according to the typechecker
    // Tdbm - Database-Model superclass
    // Tm - model subclass 
    // public function queryFirst<Tm, Tcol>(Query<Tm, Tcol> $query) : Tm;



    //
    // Migration stuff here?
    //

    // Schema version, etc

    public function migrations_enabled()    : bool; 
    public function migrations_enable()     : void; 
    public function migrations_current()    : ?migration\MigrationVersion;
    

    public function entity_out(schema\Schema $schema, string $dir, ?string $namespace = NULL) : void; 

}