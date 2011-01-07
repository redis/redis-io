Redis is what is called a key-value store, often referred to as a NoSQL
database. The essence of a key-value store is the ability to store some data,
called a value, inside a key. This data can later be retrieved only if we know
the exact key used to store it. We can use the command SET to store the value
"fido" at key "server:name":

    SET server:name "fido"

Redis will store our data permanently, so we can later ask "What is the value
stored at key server:name?" and Redis will reply with "fido":

    GET server:name => "fido"
