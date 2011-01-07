Redis also supports several more complex data structures. The first one we'll
look at is a list.  A list is a series of ordered values.  Some of the
important commands for interacting with lists are *RPUSH*, *LPUSH*, *LLEN*,
*LRANGE*, *LPOP*, and *RPOP*.  You can immediately begin working with a key as
a list, as long as it doesn't already exist as a different type.

*RPUSH* puts the new value at the end of the list.

    RPUSH friends "Tom"
    RPUSH friends "Bob"

*LPUSH* puts the new value at the start of the list.

    LPUSH friends "Sam"

*LRANGE* gives a subset of the list. It takes the index of the first element
you want to retrieve as its first parameter and the index of the last element
you want to retrieve as its second parameter. A value of -1 for the second
parameter means to retrieve all elements in the list.

    LRANGE friends 0 -1 => ["Sam","Tom","Bob"]
    LRANGE friends 0 1 => ["Sam","Tom"]
    LRANGE friends 1 2 => ["Tom","Bob"]
