# Formal languages

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

Of course there is source code that is not syntactically correct - but then it's just not "in the language".
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
+ the AST, as being structured, can be viewed as a small step towards semantics.
  It can in fact be argued that the distinction we've made is somewhat arbitrary, and even that fusing together
  syntactic and semantic analysis is advantageous. For now, however, we'll keep them separate and focus on syntax.
+ the phrase **specific to a language** (or at least me emphasizing it): by putting it in I have effectively turned
  the original word problem, which had *two* inputs (a word and a language) into a one-input problem (a word only)[^1].
  Well, breaking things up into sub-problems is perfectly reasonable. In this instance I hope to have motivated you to focus
  on the following:
  
## 4. How to define a formal language?
Since a language is nothing but a set, couldn't we just name all the elements?

Well, we can - **if:**
+ the language is finite (and small, to be practible)
+ AND: every word in the language is finite (and small... you get it)

These two restrictions already give a hint that the class of languages we can (practically) define in this way
is rather small - and not very interesting.
Additionally: this approach does not provide any means of classifying parts of words whatsoever.

Again, as you may have recognized by now, I'm trying to push you towards sub-dividing problems, or separating concerns.
The ones I'm aiming for here are:
+ feasability: how to deal with non-finiteness?
+ sheer practicality: even if theoretically possible, is it worth the effort?!
+ last, not least - *does it make sense?*
  That is: identify what it is that we want to express, break it down into parts - and **make these parse *explicit***

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

Now for the other side of the definitions. We'll allow rule names (left side of `::=`) there, which
are called *nonterminals*, btw.
However, more is needed to make things interesting. First we'll add *terminals* which will be just plain
character sequences, enclosed in double quotes:
```
  S ::= "x"
```
This defines the language that consists of only one word, namely the one-character-sequence "x".


### 5.1 Grammars: Concatenation, Alternation and Disambiguation

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

At this point - with both, concatenation and alternation - we need some means for disambiguating.
For example, what should we take the following grammar to define:
```
  S ::= "x" | "y" "z"
```
Is it `{"xz", "yz"}` or rather `{"x", "yz"}`?

**Please:** do read the previous sentence one more time! And once more. Convince yourself that both are reasonable choices - and that there are no other reasonable interpretations!

We will use parentheses `(` and `)` for disambiguation, and adopt some convention of "precedence" which will allow
for leaving off some of the parentheses for the sake of readability.
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


### 5.2 Grammars: Multiplicity

... intro `?`, `*` and `+`

In other words: ***multiplicity operators bind more strongly than concatenation and alternation***.


### 5.3 Grammars: Character classes

... intro `[abc]`, and `[a-z]`


---
[^1]: Well, I just "curried" the problem... (sorry for the rather nerdy joke, just couldn't resist)

[^2]: The language contains exactly one word, namely the infinite sequence of "x"s. Not so hard, actually. But what about this slight variation: `S ::= S "x"`? ... ;)

