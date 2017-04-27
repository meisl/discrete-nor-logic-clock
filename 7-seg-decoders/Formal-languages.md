# Formal languages

[maybe put the rest into scope, ie say that it's not complete, nor ISO, nor pure EBNF, ...]

Table of contents: [TODO: "clickable" TOC 
    (use \<a href="#section1"\> and \<p id="section1"\>)]


## 1. What's a formal language?

A *formal* language differs from a *natural* language like English in quite some ways:
+ it is a mathematical construct, precisely defined; not spoken
+ it is in fact set of *words*, where the term *word* has a precise meaning: a sequence of characters,
  possibly including whitespace like " " or the TAB or NEWLINE character
+ its words may be infinite (never-ending sequences)
+ it may or may not be infinite itself
+ it may or may not contain the empty sequence "", or "the empty word", also denoted as ε ("epsilon")

From now on we'll take the "formal" as default, so just "language" will always mean formal language,
and "word" will always mean sequence of characters, no more and no less.

## 2. What are they good for?
Well, any computer program (source code) is *a word of a certain language*, so...

Note that it's *one* word, not many.

Of course there exists source code that is not syntactically correct - but then that's simply not "in the language".
Now there are programs that *are* syntactically correct but which the compiler still keeps complaining about.
These then are in the language, but the compiler is not able to attach a *meaning* to them (or isn't sure which to attach).
This is called *semantic* incorrectness / incompleteness / ambiguity - and a separate problem.

Here we'll be concerned only with the syntax problem, or "word problem".

## 3. What's a parser?
The aforementioned word problem can be stated as: given a word and a language, is the word an element of the language?

Well, the answer isn't so exciting as such, it'll just be either Yes or No.
Things get more interesting when we ask *how* to get this answer. Obviously we want to do this in a systematic way,
and do it mechanically. Most probably we also want to (later) attach some meaning to the given word, so it'll be
helpful to extract some additional information about the word's structure.
That in fact amounts to kind of a *proof* of the final Yes/No answer.

In case of a Yes we will be able to build up some *structured* (= broken-up into classified parts) 
internal representation which can then be processed further.
In case of a No, what has been built up so far can be used to produce (hopefully) helpful error messages.

##### A **parser** is a program *specific to a language* that turns an input word into a structured representation of it (or, in case, an error message).
The structured representation is called "AST", Abstract Syntax Tree.

There are two things to note here:
+ the AST, as being structured, can be viewed as a small step towards semantics already.
  It can in fact be argued that the distinction we've made is somewhat arbitrary, and even that fusing together
  syntactic and semantic analysis is advantageous. For now, however, we'll keep them separate and focus on syntax.
+ the phrase **specific to a language** (or at least me emphasizing it): by putting it in I have effectively turned
  the original word problem, which had *two* inputs (a word and a language) into a one-input problem (a word only)[^1].
  Well, breaking things up into sub-problems is perfectly reasonable. In this instance I hope to have motivated you to focus
  on the following:
  
## 4. How to define a formal language?
Since a language is nothing but a set, couldn't we just name all the elements?

Well, we can - **if:**
+ the language is finite (and somewhat small, to be practible)
+ AND: every word in the language is finite (and somewhat small... you get it)

These two restrictions already give a hint that the class of languages we can (practically) define in this way
is rather limited - and actually not very interesting.
Additionally: this approach does not provide any means of classifying parts of words whatsoever.

Again, as you may have recognized by now, I'm trying to push you towards sub-dividing problems, or separating concerns.
The ones I'm aiming for here are:
+ feasability: how to deal with non-finiteness?
+ sheer practicality: even if theoretically possible, is it worth the effort?!
+ last, not least - *does it make sense?*
  That is: identify what it is that we want to express, break it down into parts - and **make these parts *explicit***

We'll start with addressing the last point, and add more as we go.

The formalism we will develop for defining languages is called a ***grammar***,
and its basic compounds are ***rules***. 
Each such rule represents a class in the classification we aim to make,
and there needs to be one rule picked out to be the ***start rule***.

## 5. Grammars
Actually, both grammars and rules are nothing but *definitions*: 
of languages (sets) and parts of languages (subsets of languages), respectively.
But a definition as such is a rather simple concept: attach a *name* to some other thing.
We'll use the symbol `::=` to denote this "attaching" action, so:
```
  S ::= ...
  T ::= ...
  F ::= ...
```
is one grammar with three rules, attaching names "S", "T" and "F" to ... well something.
By convention we'll consider the "S" rule - or alternatively simply the first one - as the start rule.

Now for the other side of the definitions. We'll allow rule names (left side of `::=`), or *nonterminals*
on the right side.
However, more is needed to make things interesting. First we'll add *terminals* which will be just plain
character sequences, enclosed in double quotes:
```
  S ::= "x"
```
This defines the language that consists of only one word, namely the one-character-sequence "x".


### 5.1 Grammars: Concatenation, Alternation and Grouping

Next comes ***concatenation***, which is denoted simply by putting things next to each other:
```
  S ::= "x" T
  T ::= "y"
```
This one defines the singleton (one-element-set) language of the sequence "xy". We could as well have written:
```
  S ::= "xy"
```
Here we can already see that in general there are many possible grammars for a single language.

Anyways, before introducing the next concept, let's see what we can do with what we have right now.
Consider
```
  S ::= "x" S
```
This is a proper grammar, and it does define a language. How many words does the language contain? What - if any - are those words like? [^2]

Next comes ***alternation***, or ***choice***, which lists alternatives and is denoted by putting a `|` in between:
```
  S ::= "x" | "y"
```
That's the two-word language containing "x" and "y", and nothing else.
From now on we'll use a set-like notation to talk about languages: `{'"x", "y"}` will stand for the language
containing the words "x" and "y", exactly.

At this point - with both, concatenation and alternation - we need some means of ***disambiguation***.
For example, what should we take the following grammar to define:
```
  S ::= "x" | "y" "z"
```
Is it `{"xz", "yz"}` or rather `{"x", "yz"}`?

**Please:** do read the previous sentence one more time!
And once more.
Convince yourself that both options are equally reasonable - and that these two are the *only* reasonable interpretations!

Now this is a question of ***grouping***. In the above example there are two ways of grouping things together,
but in general there may be even more.

We will use parentheses `(` and `)` to pick out the one grouping that we want, and thus get rid of this kind of ambiguitiy.
Additionally we'll adopt some convention of "precedence" which will allow
for leaving off some of the parentheses in certain cases for the sake of readability.
So, fully parenthesized,
```
  S ::= ("x" | "y") "z"
```
would define `{"xz", "yz"}` and
```
  S ::= "x" | ("y" "z")
```
would define `{"xy", "xz"}`. We'll take the latter as the default, so
```
  S ::= "x" | "y" "z"
```
will be short for
```
  S ::= "x" | ("y" "z")
```
In other words: ***concatentation binds more strongly than alternation***.

Note that this is the *convention*, which introduces an ***implicit grouping***, 
whereas `(` and `)` are used for ***explicit grouping***. 
Each of the two alone would be sufficient for *disambiguation*, 
but using only one of them - rather than both in combination - has its downsides:
- only the convention: as it "throws away" all but one of the possible groupings, it effectively reduces expressive power! Even though it might still be possible to define the intended language by a different grammar, these work-arounds will basically be nothing but resorting to "list all elements". Not even does this defeat our intention of structuring, it also excludes a large class of interesting languages.  
- only `(` and `)`: no reduction of expressive power, but it'll become harder and harder to read (as a human) the more levels of nesting there are - and there'll be a lot for all but the very trivial grammars


[TODO: hand-wavy argument about expressive power - proof?]


### 5.2 Example: A grammar for logic expressions

We've now covered enough to look at our first actually useful example grammar.
A rough characterization of what its language can be taken as would be
"Expressions of propositional logic".
It has only three logical operators,
but it does introduce *object-level* parentheses (see 5.2.2 and 5.2.3).
If those parentheses were omitted, what remains would be
"sum-of-products", or logic expressions
in ["Disjunctive Normal Form" (DNF)](https://en.wikipedia.org/wiki/Disjunctive_normal_form).


But remember: as of now such an interpretation is no more than a mental aid.
The *actual* interpretation - which means processing an AST and transforming it into some output value - will be covered later on.
Here's the grammar:
```
  S ::= T | T "+" S
  T ::= F | F "*" T
  F ::= C | I | N | "(" S ")"
  C ::= "0" | "1"
  I ::= "A" | "B" | "C" | "D"
  N ::= "!" F
```

#### 5.2.1 Basic parts: non-terminals for structure, terminals for the alphabet

The nonterminals are chosen as to give some hint at their intended purpose:
- `S`: "Start"
- `T`: "Term"
- `F`: "Factor"
- `C`: "Constant"
- `I`: "Identifier"
- `N`: "Negation"

As for the terminals, there are
- operators: `"+"` for "OR", `"*"` for "AND" and `"!"` for "NOT"
- constants: `"0"` for "FALSE" and `"1"`  for "TRUE"
- identifiers: `"A"` ... `"D"` as variables (variable *names*, to be precise)
- parentheses: `"("` and `")"` for grouping

Looking at the terminals alone already tells us which characters can appear at all in words of the language.
This set of characters that can appear at is called the ***alphabet of the language***.
In particular, there is no whitespace in the alphabet, so for example "A + B" will definitely NOT be
in the language, whereas "A+B" might be (and actually is).


#### 5.2.2 Grouping revisited (1): object-level vs meta-level

Regarding `"("` and `")"`, it is important to understand how they are different from `(` and `)`:
The former are terminals, and as such occur as parts of words *of the object language*, ie. the
language being defined by the grammar.
On the other hand, `(` and `)` are symbols used *in the grammar formalism itself*, they are meta symbols.
However, both, the object and the meta symbols, are used for pretty much the same purpose, which is grouping.
<br>The difference is in the level on which each pair of symbols is used:
***the object-level vs the meta-level***.


#### 5.2.3 Grouping revisited (2): Parentheses better be balanced!

Of course we expect parentheses to be balanced, ie.: every opening parenthesis must eventually be paired up with a
closing one, and it should be unambiguous which to pair up with which.

Above, under 5.2, when we introduced parentheses on the meta-level we didn't
even mention that - and I think we actually hadn't to.
The concept of grouping - as well as the need for it - is just immediately evident.
Likewise, putting symmetrical-looking symbols `(` and `)` around the intended groups,
just comes naturally[^3].

However, now that we know how to tell apart object-level from meta-level,
and have introduced object-level parentheses in our example grammar, we can no
longer take *their* balancedness just for granted.

So: how to prove that every word in the language of logic expressions has balanced parentheses?

Well, the only way of matching a `"("` is by following the last alternative of the `F` rule, namely
`"(" S ")"`. But this is a concatenation, so we must then also see an `S` and finally a `")"`.
So the initial `"("` is indeed paired with the final `")"`, from which we get two things:
- a) the nr of opening parentheses equals the nr of closing ones
- b) for every `"("`, the `")"` is *uniquely determined*

Also: *If the inner `S` has balanced parentheses*, 
then so has the whole thing matched by the last alternative of the `F` rule.
Observe that `S` is the start rule, so what's in between `"("` and `")"` is also a word of the
language - but a *smaller* one! This reasoning is top-down, since we went from a larger word to a
smaller one.
<br>
Let's now take a bottom-up view, and start with a word in the language *that has no parentheses at all*.
Such words definitely exist: the single constants `"0"` or `"1"` are examples, 
as is a single identifier like "A".
All such words have balanced parentheses in a trivial sense: namely none at all.

But since all other words in the language (words that really do contain parentheses)
can be built up *only* through the last alternative of  the `F` rule,
these must have balanced parentheses, too!
<br>
Note: this proof also covers all the *infinite* words (of which there are indeed some in the language).
Well, in practice infinite words actually won't matter too much, but it's nice to know, isn't it?


#### 5.2.4 Derivations, ASTs and Operator precedence

Putting aside parentheses for a moment, let's look at words with operators in them; for example `"A+B*C"`.


Starting with the `S` rule, we first have to choose between the alternatives `T` or `T "+" S`. It cannot
be just `T` because we have to match the `"+"` sometime, and the only rule to do so is `S`. 
However, if we went down the `T` part of it, then the only way to get back to `S` is through `"("` and
`")"` - but there are none in `"A+B*C"`.

So, by following the `T "+" S` branch of `S` we are done with the `"+"` and left with two sub-problems,
namely
- derive `"A"`, starting at `T`
- derive `"B*C"` starting at `S`

The first one's easy: the (only) sequence of rules to follow is `T`, `F`, `I`.
<br>
The reasoning for the other goes like this:
- at `S`: must follow `T` because there is no (more) "+"
- at `T`: must follow `F "*" S` because there are no parentheses
- at which point we're left only with variable names, which should be clear by now

All this reasoning, that is precisely describing which rules to follow s.t. a particular word is matched - is 
called a ***derivation*** *of the word*. Apart from using plain English it can also be represented by
a so-called ***derivation tree***:
```
"A+B*C"
~> S
   ├─T
   │ └─F
   │   └─I
   │     └─"A"
   ├─"+"
   └─S
     └─T
       ├─F
       │ └─I
       │   └─"B"
       ├─"*"
       └─T
         └─F
           └─I
             └─"C"
```
Now, such a full derivation tree is quite a monstrosity, even for rather small words like `"A+B*C"`.
That is because each and every rule produces a node of its own - even if all it did was
nothing but to refer to yet another rule.
<br>
So one thing we can do is to collapse such linear branches into just the leaf node,
where for constants (`C`) and identifiers (`I`)
we'll keep the information through which of the two the terminal was derived.
<br>
Another is to (systematically) re-organize the parts of a concatenation.
Here we'll do it like so:
- binary operators `"+"` and `"*"` replace their parent node (`S` or `T`, resp.), and are labelled "op2"
- the unary operator `"!"` replaces its parent (`N`), and is labelled "op1"
- parentheses `"("` and `")"` are omitted altogether: at this point they will have done their job (we'll address what
  that was exactly further down)

Applying these transformations to the derivation tree finally yields the desired AST (Abstract Syntax Tree):
```
"A+B*C"
~> op2:"+"
      ├─I:"A"
      └─op2:"*"
           ├─I:"B"
           └─I:"C"
```
Notice that `"+"` ends up one level above `"*"`.

Next, let's derive another word: `"B*C+A"`.
<br>
**Please try for yourself before you read on!**
<br>
Maybe you can even come up with an argument why your solution is the only one possible?

```
"B*C+A"
~> op2:"+"
      ├─op2:"*"
      │    ├─I:"B"
      │    └─I:"C"
      └─I:"A"
```
Notice that again the `"+"` ends up one level above `"*"`, even though here `"+"` appears *after* the `"*"` in the input word.

This is not a coincidence, but actually enforced by the grammar.
In this sense - ie `"*"`-expressions are grouped together, and only then `"+"`-expressions - the grammar makes `"*"` ***bind more strongly than*** `"+"`.
<br>
It (the grammar) does this "automatically", or as it is said "by construction" (of the grammar that is, NOT of a word).

It even works as expected if we add negation `"!"` to the mix, which will bind more strongly than both, `"+"` and `"*"`:
```
A*!B+!C*D
~>
  op2:"+"
     ├─op2:"*"
     │    ├─I:"A"
     │    └─op1:"!"
     │         └─I:"B"
     └─op2:"*"
          ├─op1:"!"
          │    └─I:"C"
          └─I:"D"
```

The precendence rules imposed by this grammar can also be stated as:
<br>
The AST for any of its language's (sub-) words *without parentheses* cannot contain
- a `"+"` node below a `"!"` node
- a `"*"` node below a `"!"` node
- a `"+"` node below a `"*"` node

**Exercise:** prove the above statement in the style of 5.2.3 ("Balanced parentheses")


#### 5.2.5 A derivation requiring all features of the language
[TODO: come up with a meaningful word requiring every rule]
`"A*(B+!C)+!C*D+0+B*1"`
[TODO: add solution AST]


#### 5.2.6 Thinking further - richer languages with less effort?
[TODO: motivate below chapter "Multiplicity" (for whitespace and op2-rules)]
[TODO: motivate below chapter "Character classes" (for identifiers)]



### 5.3 Grammars: Multiplicity

... intro `?`, `*` and `+`

In other words: ***multiplicity operators bind more strongly than concatenation and alternation***.


### 5.4 Grammars: Character classes

... intro `[abc]`, and `[a-z]`


---
[^1]: Well, I just "curried" the problem... (sorry for the rather nerdy joke, just couldn't resist)

[^2]: The language contains exactly one word, namely the infinite sequence of "x"s. Not so hard, actually. But what about this slight variation: `S ::= S "x"`? ... ;)

[^3]: `(` and `)` can actually be viewed as *one* operator (note: *one*, NOT two). Just in case you wanna show off: such an operator is classified as a "circumfix"-operator.
