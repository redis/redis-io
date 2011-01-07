*SISMEMBER* tests if the given value is in the set.

    SISMEMBER superpowers "flight" => true
    SISMEMBER superpowers "reflexes" => false

*SMEMBERS* returns a list of all the members of this set.

    SMEMBERS superpowers => ["flight","x-ray vision"]

*SUNION* combines two or more sets and returns the list of all elements.

    SADD birdpowers "pecking"
    SADD birdpowers "flight"
    SUNION superpowers birdpowers => ["flight","x-ray vision","pecking"]
