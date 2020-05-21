namespace catarini\db;

abstract class Model<T> { 

    protected DatabaseInstance $DB;
    public function __construct(DatabaseInstance $DB) { 
        $this->DB = $DB;
    }

    public function q() : Query<this, T> { return new Query<this, T>($this->DB, $this); }

    // For now, defining this shit here:
    // - "new" method 

}