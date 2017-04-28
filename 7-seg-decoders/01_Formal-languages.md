# Formal languages


[maybe put the rest into scope, ie say that it's not complete, nor ISO, nor pure EBNF, ...]



Table of contents
---- 
 - [1. Getting started](#1-getting-started")
    - [1.1. What’s a formal language?](#1-whats-a-formal-language)
      - [1.1.1 Foo bar blah](#111-foo-bar-blah)

[TODO: "clickable" TOC]

---

[TOC]



## 1. Getting started

### 1.1. What's a formal language?

A *formal* language differs from a *natural* language like English in quite some ways:

- it is a mathematical construct, precisely defined; not spoken
- it is in fact set of *words*, where the term *word* has a precise meaning: a sequence of characters,
  possibly including whitespace like " " or the TAB or NEWLINE character
- its words may be infinite (never-ending sequences)
- it may or may not be infinite itself
- it may or may not contain the empty sequence "", or "the empty word", also denoted as ε ("epsilon")

From now on we'll take the "formal" as default, so just "language" will always mean formal language,
and "word" will always mean sequence of characters, no more and no less.

### 1.2. What's it good for?

Well, any computer program (source code) is *a word of a certain language*, so...

Note that it's *one* word, not many.

Of course there exists source code that is not syntactically correct - but then that's simply not "in the language".
Now there are programs that *are* syntactically correct but which the compiler still keeps complaining about.
These then are in the language, but the compiler is not able to attach a *meaning* to them (or isn't sure which to attach).
This is called *semantic* incorrectness / incompleteness / ambiguity - and a separate problem.

Here we'll be concerned only with the syntax problem, or "word problem".

### 1.3. What's a parser?

The aforementioned word problem can be stated as: given a word and a language, is the word an element of the language?

Well, the answer isn't so exciting as such, it'll just be either Yes or No.
Things get more interesting when we ask *how* to get this answer. Obviously we want to do this in a systematic way,
and do it mechanically. Most probably we also want to (later) attach some meaning to the given word, so it'll be
helpful to extract some additional information about the word's structure.
That in fact amounts to kind of a *proof* of the final Yes/No answer.

In case of a Yes we will be able to build up some *structured* (= broken-up into classified parts) 
internal representation which can then be processed further.
In case of a No, what has been built up so far can be used to produce (hopefully) helpful error messages.

---
A **parser** is a program *specific to a language* that turns an input word into a structured representation of it (or, in case, an error message). The structured representation is called **"AST", Abstract Syntax Tree**.

---

There are two things to note here:

 - the AST, as being structured, can be viewed as a small step towards semantics already.
  It can in fact be argued that the distinction we've made is somewhat arbitrary, and even that fusing together
  syntactic and semantic analysis is advantageous. For now, however, we'll keep them separate and focus on syntax.
 - the phrase **specific to a language** (or at least me emphasizing it): by putting it in I have effectively turned
  the original word problem, which had *two* inputs (a word and a language) into a one-input problem (a word only)[^1].

Well, breaking things up into sub-problems is perfectly reasonable. In this instance I hope to have motivated you to focus
  on the following:
  
### 1.4. How to define a formal language?

Since a language is nothing but a set, couldn't we just name all the elements?

Well, we can - **if:**

 - the language is finite (and somewhat small, to be practible)
 - AND: every word in the language is finite (and somewhat small... you get it)

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

## 2. Grammars

Actually, both grammars and rules are nothing but *definitions*: of languages (sets) and parts of languages (subsets of languages), respectively.
But a definition as such is a rather simple concept: attach a *name* to some other thing.
We'll use the symbol `::=` to denote this "attaching" action, so:
```
  S ::= ...
  T ::= ...
  F ::= ...
```
is one grammar with three rules, attaching names "S", "T" and "F" to ... well something.
By convention we'll consider the "S" rule - or alternatively simply the first one - as the start rule.


### 2.1. Terminals and escaping

Now for the other side of the definitions. We'll allow rule names which we had on the left-hand-side (lhs) of `::=`, or *nonterminals* on the right-hand-side (rhs) as well.
However, more is needed to make things interesting. First we'll add *terminals* which will be just plain character sequences, enclosed in double quotes:
```
  S ::= "x"
```
This defines the language that consists of only one word, namely the one-character-sequence "x".

The enclosing double quotes serve to tell apart character sequences from names: `"x"` is a char-sequence, whereas `x` is a rule name. But what if we want to talk about the character sequence that consists of a double quote itself (as a character)?

For this we need a special symbol indicating that the following `"` is NOT the start or end of a terminal but rather the double quote character as such. This is called ***escaping*** and we'll use the backslash `\` for this purpose:
```
  S ::= "\""
``` 
properly defines the language of the one-character word that consists just of the double quote character.

However, now we cannot denote the backslash character anymore! Well, why not apply the very same trick again? Let's just say that `\` not "disables" a subsequent `"` but also a subsequent `\`. This indeed solves the problem: the backslash character as such is denoted by the terminal `"\\"`.

Another use of the escaping `\` is to denote *unprintable* characters like TAB, NEWLINE and RETURN. We'll do so by writing `"\t"`, `"\n"` and `"\r"`, respectively.


### 2.2. Concatenation, Alternation and Grouping

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

Anyways, before introducing the next concept, let's see what we can do with what we have already. Consider
```
  S ::= "x" S
```
This is a proper grammar, and it does define a language. How many words does the language contain? What - if any - are those words like? [^infinite-xs]

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
Additionally we'll adopt a convention of "precedence" which will allow
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

Note that this is the *convention*, which introduces ***implicit grouping***, whereas `(` and `)` are used for ***explicit grouping***. 
Each of the two alone would be sufficient for *disambiguation*, 
but using only one of them - rather than both in combination - has its downsides:
- only the convention: as it "throws away" all but one of the possible groupings, it effectively reduces expressive power! Even though it might still be possible to define the intended language by a different grammar, these work-arounds will basically be nothing but resorting to "list all elements". Not even does this defeat our intention of structuring, it also excludes a large class of interesting languages.  
- only `(` and `)`: no reduction of expressive power, but it'll become harder and harder to read (as a human) the more levels of nesting there are - and there'll be a lot for all but the very trivial grammars


[TODO: hand-wavy argument about expressive power - proof?]


### 2.3. Example: A grammar for logic expressions

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

#### 2.3.1. Basic parts: non-terminals for structure, terminals for the alphabet

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
This set of characters that can appear at all is called the ***alphabet of the language***.
In particular, there is no whitespace in the alphabet, so for example "A + B" will definitely NOT be in the language, whereas "A+B" might be (and actually is).


#### 2.3.2. Grouping revisited (1): object-level vs meta-level

Regarding `"("` and `")"`, it is important to understand how they are different from `(` and `)`:
the former are enclosed in double quotes, so they are terminals.
As such they occur as parts of words *of the object language*, ie. the
language being defined by the grammar.
On the other hand, `(` and `)` (without quotes) are symbols used *in the grammar formalism itself*, they are meta symbols.
However, both, the object and the meta symbols, are used for pretty much the same purpose, which is grouping.
<br>The difference is in the level on which each pair of symbols is used:
***the object-level vs the meta-level***.


#### 2.3.3. Grouping revisited (2): balanced parentheses

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


### 2.4. Derivations, ASTs and operator precedence

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

This is not a coincidence, but actually enforced by the grammar. In this sense - that is `"*"`-expressions are grouped together first, 
and only then `"+"`-expressions - ***the grammar makes `"*"` bind more strongly than*** `"+"`. It (the grammar) does this "automatically", or as it is said "by construction" (of the grammar that is, NOT of a word).

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
In the AST for any of its language's (sub-) words *without parentheses*
- a `"+"` node will never appear below a `"*"` node
- a `"+"` node will never appear below a `"!"` node
- a `"*"` node will never appear below a `"!"` node

**Exercise:** prove the above statement in the style of 5.2.3 ("Balanced parentheses")
[solution[^solutionEx5.2.4]]



### 2.5. Operator associativity

Up until now we have only looked at words that contained any operator at most once. But what if there are more, like in `"A+B+C+D"`?
Is it arbitrary which `"+"` to derive first? This question is very similar to that of operator precedence, only that it's now about the same operator occurring in multiple locations.

But the grammar does impose a "convention" in this case, too. It forces us to derive *the left-most `"+"` first*. That is because the recursion back to `S` only appears on the right side of `"+"`, to the effect that the input word has to be split in a way s.t. there are no more `"+"` in the left sub-word. Otherwise this left sub-word wouldn't be derivable itself.

The resulting AST is a right-leaning chain of `"+"`s:
```
"A+B+C+D"
~> op2:"+"
      ├─I:"A"
      └─op2:"+"
           ├─I:"B"
           └─op2:"+"
                ├─I:"C"
                └─I:"D"
```
The way we depict trees makes it a bit hard to see that the chain is in fact leaning to the right. Imagine that the first child is drawn on the left and the second on the right, like so:
```
"A+B+C+D"
~>        op2:"+"
           /   \
       I:"A"   op2:"+"
                /   \
            I:"B"   op2:"+"
                    /   \
                I:"C"   I:"D"
```
The grammar makes `"+"` ***associate to the right***, or ***right-associative***.

If we want a left-leaning tree we have to use parentheses:
```
"((A+B)+C)+D"
~>         op2:"+"
            /   \
       op2:"+"  I:"D"
        /   \
   op2:"+"  I:"C"  
    /   \
I:"A"   I:"B"
```
or with the usual way of depicting trees:
```
"A+B+C+D"
~> op2:"+"
      ├─op2:"+"
      │    ├─op2:"+"
      │    │    ├─I:"A"
      │    │    └─I:"B"
      │    └─I:"C"
      └─I:"D"
```
The same is true for `"*"` because its rule `T` has the very same structure as `S`.

**Exercise:** Change the grammar s.t. `"*"` associates to the left. Verify your solution by deriving `"A*B*C*D"`. What problem arises? How can it be solved?
[solution[^solutionEx5.2.5a]]

**Exercise:** With the original grammar, derive `"A*(B+!C)+!C*D+0+B*1"`.
[solution[^solutionEx5.2.5b]]
[TODO: add solution AST]


### 2.6. Multiplicity

The `S` rule of our grammar for Logic expressions
```
  S ::= T | T "+" S
```
can be read as "an `S` is either a `T`, or a `T` followed by a `"+"` followed by an `S`".
<br>
But isn't that the same as "an `S` is a `T`, *maybe* followed by a `"+"` and another `S`"?

Well, sure it is. And the way to express it directly in a grammar is to use the meta-symbol `?` as a postfix operator meaning "zero-or-once". With this our grammar can be written as
```
  S ::= T ("+" S)?
  T ::= F ("*" T)?
  F ::= C | I | N | "(" S ")"
  C ::= "0" | "1"
  I ::= "A" | "B" | "C" | "D"
  N ::= "!" F
```
A similar operator is postfix `*` (again on the meta-level, not to be confused with the terminal `"*"`!). It stands for "any number of times, including zero". We will use it to allow arbitrary whitespace in the input words, just as a convenience. In the AST, however, whitespace will be omitted, as it bears no meaning at all. We consider the space character `" "` and the TAB character, denoted by `"\t"` as whitespace.
```
  S ::= W* T W* ("+" S)?
  T ::= F ("*" W* T)?
  F ::= C | I | N | "(" S ")"
  C ::= "0" | "1"
  I ::= "A" | "B" | "C" | "D"
  N ::= "!" W* F
  W ::= " " | "\t"
```
So the new rule `W` matches one whitespace character, and is used twice in `S` and once in `N`.

The last multiplicity operator is a variation of `*`:  `+` meaning "once-or-more". We'll be using it in conjunction with the character classes from the next section.

Note that the three multiplicity operators `?`, `*` and `+` do not add to the expressive power of grammars, at least not in a theoretical sense. That is: they are just abbreviations for certain constructs that could be built with concatenation, alternation and recursion alone.

Finally we need to state two conventions regarding `?`, `*` and `+`:

- ***multiplicity operators are "greedy": they always match as much as possible***
- ***multiplicity operators bind more strongly than concatenation and alternation***


### 2.7. Character classes
There is one quirk left in our grammar of Logic expressions: we have only four different identifiers, and each is just a single letter. Again, we *could* studiously list all the letters of the (English) alphabet, and then again for lower case.
Well, not only would that be a lot of letters, but also a lot of `|` and even more `"` (meta-)symbols. Let's instead introduce another abbreviation, and have circumfix `[` `]` around plain object-level symbols
```
  [ABCD]
```
stand for
```
	("A" | "B" | "C" | "D")
```
Notice the additional parentheses in the latter. That is to indicate that

***character-class delimiters `[` and `]` bind more strongly than anything else***

So with this we can write the `C` and `W` rule as
```
  C ::= [01]
  W ::= [ \t]
```
Notice the escaping `\`: without it we would denote a lower-case t rather than TAB.

For the `I` rule, identifiers, we introduce another very handy abbreviation, namely character *ranges*:
Let
```
  [A-Z]
```
stand for
```
  ("A" | "B" | ... | "Y" | "Z")
```
and
```
  [A-Z0-9abc]
```
stand for
```
  ([A-Z] | [0-9] | [abc])
```

Now this obviously assumes some order on the alphabet, say ASCII or Unicode.
Also, since `...` isn't really defined the above isn't really a proper definition either. Anyways, I'm pretty sure you get it.

Finally there is one special character class, or range: the whole alphabet itself. That means really any character[^any-character] that there is, not just letters. We will denote this class by a single dot `.`, NOT surrounded by `[` and `]`. Note: `[.]` would match the object-level dot, just like `"."`, and nothing else.

So, with everthing together, here's the final grammar for Logic expressions:

```
  S ::= W* T W* ("+" S)?
  T ::= F ("*" W* T)?
  F ::= C | I | N | "(" S ")"
  C ::= [01]
  I ::= ([a-z] | [A-Z])+
  N ::= "!" W* F
  W ::= [ \t]
```

## 3. A grammar for grammars

With grammar for logic expr: saw patterns from meta level recur on object level.
Found solutions on object level.
Why not use these to write a grammar that defines the language of grammars?

### 3.1. A few more conventions

Rules with rhs a concatenation or alternation of only literals and possibly multiplicity ops get names starting with a lower-case letter.

All other rules get names starting with an upper-case letter.

Won't enforce these conventions for object-level grammars, just use them for the meta-grammar.

### 3.2. A grammar is a list of rules
```
       ws ::= [ \t]
       nl ::= "\n"
    ident ::= [A-Za-z]+
     mult ::= [*?+]
     
  
    Grammar ::= StartRule (nl+ Rule)*
  StartRule ::= Rule
```
The extra `StartRule` rule may look bogus, but it makes explicit that every grammar has one special rule: the start rule.


### 3.3. The rule for rules

Due to concatenation having precedence over alternation we can state that a rule's right-hand-side (rhs) is generally an alternation of concatenations. This includes alternations with just one alternative, as well as concatenations of just one element.

Regarding precedence we observe that alternation and concation are for grammars what are addition `"+"` and `"*"` for logic expressions. So we will adapt the pattern with right-recursion from there.

But first we have express that a rule has lhs (`ident`), `"::="` and rhs (`Alt` for alternation, corresponds to `S` in logic expressions).
```
           Rule ::= ws* ident ws* "::=" Alt
		    Alt ::= ws* Con ws* ("|" Alt)?
            Con ::= Atom mult? (ws+ Con)?
           Atom ::= "(" Alt ")"
                  | Terminal
                  | CClass
```
Let's have a closer look at the `Con` rule ("concatenation"). It corresponds to the `T` rule from logic expressions, but in contrast to multiplication we do not have any symbol for the concatenation operator. That's not a big problem, we just leave it out. The only thing to change is that we now must require at least one preceding `ws` before the recursive `Con` s.t. it's properly separated from what comes before it.

Another difference is that the optional `mult` is postfix, rather than prefix as unary negation `"!"` in logic expressions.

The name "Atom" may seem strange since the very first alternative of `Atom` is a concatenation of three! However, at this point we're done with the two main concepts of alternation and concatenation, so with regard to *them* everything from here on is indeed indivisible.

`Atom` corresponds to `F` so it is here where we cover parentheses. Similarly, `Terminal` corresponds to `C` but it's a bit more complicated, and even more so are character classes, `CClass`.

### 3.4. The rule for terminals

Well, they have double quotes `"` around them. The simplest way to  write these as terminals (themselves) is a single-char character class: `["]`.
What's in between is a bit more complicated:
```
  Terminal ::= ["] (escQ | [-"\\])+ ["]
      escQ ::= "\\" [nrt\\]
```
Here we formally define the **escaping mechanism for double quotes**, just as we did in plain English in [2.1 Terminals and escaping](#21-terminals-and-escaping).

`"\""` is an object-level `"` and `"\\"` is an object-level `\`. `"\n"`, `"\r"` and `"\t"` denote NEWLINE, RETURN and TAB, respectively. So that's `escQ` ("escape quotes").

Besides those escape sequences we want to allow *anything but* (unescaped) `"` and `\`. For this we use the **negative character class** `[-"\\]` which says exactly that: *anything but*...
Note that inside a character class - negative or positive - there is no need to require `"` to be escaped, but `\` still needs to be escaped since we'll use again for the escaping mechanism for character classes.


### 3.5. The rule for character classes

The simplest character class to define is dot: `"."`. All others are enclosed by `[` and `]` and may either be negative or positive, indicated by presence, or non-presence of a `-` right after the opening `[`, resp. (`NCList` or `PCList`, just like negation `"!"` in logic expressions).
```
  CClass ::= "." | ("[" (NCList | PCList) "]")
  NCList ::= "-" PCList
  PCList ::= (escC | [-\[\-\]\\])+
  CRange ::= PCList "-" PCList (PCList | CRange)+
    escC ::= "\\" [nrt\[\-\]\\"]
```
Again we need an ***escaping mechanism***, now ***for character classes***. Escape sequences are defined by `escC`; as usual they consist of one (!) `\` (denoted by `"\\"`), followed by

 - `n`, `r`, `t` for unprintable characters
 - single `\` - denoted by `\\` inside char class - for the backslash itself
 - "trouble-makers" w.r.t. character class notation, namely `[`, `-` and `]`
 - finally `"` which we actually don't need to require escaping but by adding it here we can *allow* it to be escaped. It is so common to escape `"` when the object level is meant, so by simply allowing it even if not strictly necessary just makes people happier.

So now `PCList` follows the same pattern as double quotes above: one or more of either an escape sequence `escC` or *anything but* the "trouble makers".

TODO: character ranges


[^1]: Well, I just "curried" the problem... (sorry for the rather nerdy joke, just couldn't resist)

[^infinite-xs]: The language contains exactly one word, namely the infinite sequence of "x"s. Not so hard, actually. But what about this slight variation: `S ::= S "x"`? ... ;)

[^3]: `(` and `)` can actually be viewed as *one* operator (note: *one*, NOT two). Just in case you wanna show off: such an operator is classified as a "circumfix"-operator.

[^solutionEx5.2.4]: We'll prove "`"+"` never below `"!"`"; the argument is pretty much the same for the others. Firstly, the derivation-tree-to-AST transformation never promotes an operator node beyond its direct parent. Therefore it is sufficient to prove the statement for the derivation tree: in order to get to the `N` rule, which derives the `"!"`, the derivation must inevitable go through the `S` rule *first*. But there is the only opportunity to derive any, and all `"+"`s - remember: no parentheses, so we will never get back to `S` again. Hence after that the input word has been split up into sub-words, none of which contains a `"+"`. So any derivation of a `"!"` must happen further down the tree than any `"+"` node.

[^solutionEx5.2.5a]: `T ::= F | T "*" F`, make `T` left-recursive. But the recursion - should we choose the second alternative - now happens before anything else is derived - and we are immediately faced with the very same decision to make again! One might think of some way of "looking ahead" in order to make this decision. But how far? In fact, the length of the sub-word derived by `T` can be arbitrarily long. A better solution is to not use left-recursion at all and instead transform the AST at (and below) those operator nodes for which left-associativity is desired.

[^solutionEx5.2.5b]: TODO

[^any-character]: The "Any" character is the character produced by the ominous "Any" key, which so many people never could find on their keyboard. 
