namespace catarini\db\schema;

type Schema = vec<Table>;

/*
    This will need to be expanded - it'll need to contain information about
        record associations at least.  
    This is also where we can include information like differences in table names
        vs entity class names, stuff like that for backwards compatibility
 */