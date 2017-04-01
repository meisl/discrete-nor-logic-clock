## Minimal NOR-only circuits from Karnaugh-maps
Karnaugh-maps, or K-maps for short, are designed to find minimal sum-of-products.
....

### NOR-only sums
An OR in terms of NOR is pretty straight-forward: the sum of n terms

    T1 OR T2 OR ... OR Tn = OR(T1, ...., Tn)

can be expressed as

    - NOR(T1, ..., Tn)

Notice the additional negation on the outside that makes up for the implicit negation that the NOR introduces.
So in order to have this implicit negation from the NOR work for us instead of against us, we will be looking
for *minterms* (0s in the K-map) rather than *maxterms* (1s in the K-map).

Example: ...


### NOR-only products
Compare the truth tables of binary AND and binary NOR:

...truth tables...

Both have only one 1 entry but in different rows.
- AND yields 1 only if all inputs are 1
- NOR yields 1 only if all inputs are 0

Therefore, in order to produce the same result as an AND, we must *invert all inputs* before feeding them into the NOR.

This generalizes to n-ary AND/OR.

Thus a product of n factors
    
    AND(F1, ..., Fn)
    
can be expressed as
  
    NOR(-F1, ..., -Fn)



### One-factor-only products
...

### One-term-only sums
...

### Putting it together (in two stages)
...

### Further optimization (more than two stages)
...
