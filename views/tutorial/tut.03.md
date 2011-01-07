There is something special about INCR.  Why do we provide such an operation if
we can do it ourself with a bit of code? After all it is as simple as:

    x = GET count
    x = x + 1
    SET count x

The problem is that doing the increment in this way will only work as long as
there is a single client using the key. See what happens if two clients are
accessing this key at the same time:

1. Client A reads *count* as 10.
2. Client B reads *count* as 10.
3. Client A increments 10 and sets *count* to 11.
4. Client B increments 10 and sets *count* to 11.

We wanted the value to be 12, but instead it is 11! This is because
incrementing the value in this way is not an atomic operation.  Calling the
INCR command in Redis will prevent this from happening, because it *is* an
atomic operation. Redis provides many of these atomic operations on different
types of data.
