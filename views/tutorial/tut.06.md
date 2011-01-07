*LLEN* returns the current length of the list.

    LLEN friends => 3

*LPOP* removes the first element from the list and returns it.

    LPOP friends => "Sam"

*RPOP* removes the last element from the list and returns it.

    RPOP friends => "Bob"

Note that the list now only has one element:

    LLEN friends => 1
    LRANGE friends 0 -1 => ["Tom"]
