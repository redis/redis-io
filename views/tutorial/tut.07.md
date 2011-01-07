The next data structure that we'll look at is a set. A set is similar to a
list, except it does not have a specific order and each element may only appear
once. Some of the important commands in working with sets are *SADD*, *SREM*,
*SISMEMBER*, *SMEMBERS* and *SUNION*.

*SADD* adds the given value to the set.

    SADD superpowers "flight"
    SADD superpowers "x-ray vision"
    SADD superpowers "reflexes"

*SREM* removes the given value from the set.

    SREM superpowers "reflexes"
