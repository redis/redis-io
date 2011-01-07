Redis can be told that a key should only exist for a certain length of time.
This is accomplished with the *EXPIRE* and *TTL* commands.

    SET resource:lock "Redis Demo"
    EXPIRE resource:lock 120

This causes the key *resource:lock* to be deleted in 120 seconds. You can test
how long a key will exist for with the *TTL* command. It returns the number of
seconds until it will be deleted.

    TTL resource:lock => 113
    TTL count => -1

The *-1* for the *TTL* of the key *count* means that it will never expire. Note
that if you *SET* a key, its *TTL* will reset.

    SET resource:lock "Redis Demo 1"
    EXPIRE resource:lock 120
    TTL resource:lock => 119
    SET resource:lock "Redis Demo 2"
    TTL resource:lock => -1
