The last data structure which Redis supports is the sorted set.  It is similar
to a regular set, but now each value has an associated score.  This score is
used to sort the elements in the set.

    ZADD hackers 1940 "Alan Kay"
    ZADD hackers 1953 "Richard Stallman"
    ZADD hackers 1965 "Yukihiro Matsumoto"
    ZADD hackers 1916 "Claude Shannon"
    ZADD hackers 1969 "Linus Torvalds"
    ZADD hackers 1912 "Alan Turing"

In these examples, the scores are years of birth and the values are the names
of famous hackers.

    ZRANGE hackers 2 4 => ["Alan Kay","Richard Stallman","Yukihiro Matsumoto"]
