#!/usr/bin/python

# we use bytearrays as index in dictionary, make it hashable
class HashableBytearray(bytearray):
    def __hash__(self):
        return hash(self.hex())
    
    def __add__(self, other):
        return HashableBytearray(super().__add__(other))

    def __str__(self):
        return super().__str__().replace('bytearray(', 'hb(').replace("HashableBytearray(", "hb(")

    def __repr__(self):
        return super().__repr__().replace('bytearray(', 'hb(').replace("HashableBytearray(", "hb(")