Other common operations provided by key-value stores are DEL to delete a given
key and associated value, SET-if-not-exists (called SETNX on Redis) that sets a
key only if it does not already exist, and INCR to atomically increment a
number stored at a given key:

    SET connections 10
    INCR connections => 11
    INCR connections => 12
    DEL connections
    INCR connections => 1
