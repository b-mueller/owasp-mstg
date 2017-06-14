# Style Guide

The following rules are meant to ensure consistency of the MSTG:

1. Keep the content factual, brief and focused. Avoid duplicating other sections of the guide;
2. Refrain from advertising commercial tools or services;
3. When giving technical instructions, address the reader in the second person.

## Title Capitalization

We follow the title case rules from the "Chicago Manual of Style":  

- Capitalize the first and last word in a title, regardless of part of speech
- Capitalize all nouns (baby, country, picture), pronouns (you, she, it), verbs (walk, think, dream), adjectives (sweet, large, perfect), adverbs (immediately, quietly), and subordinating conjunctions (as, because, although)
- Lowercase “to” as part of an infinitive
- Lowercase all articles (a, the), prepositions (to, at, in, with), and coordinating conjunctions (and, but, or)

When in doubt, you can verify proper capitalization on [www.titlecapitalization.com](http://www.titlecapitalization.com/).

## External References

External references are listed at the end of each chapter. Refer to them by number within the text, e.g.: &lt;sup&gt;[1]&lt;/sup&gt;. Remember that the MSTG is supposed to work as a printed document, so always include the full URL like in the examples below (hrefs that hide the URL will obviously be problematic in the print version).

See the [test case template](Templates/testcase.md) for more examples.

### Web Links

Links to sources on the web look as follows:

- [1] Reference Name - http://www.example.com/full-link-1.html
- [2] Reference Name - http://www.example.com/full-link-2.html

For example:

- [1] NIST, the economic impacts of inadequate infrastructure for software testing - http://www.nist.gov/director/planning/upload/report02-3.pdf

### Link to Books and Papers

__Papers:__ 
The general form for citing technical reports is to place the name and location of the company or institution after the author and title and to give the report number and date at the end of the reference. 

Basic Format: 

- [1] J. K. Author, “Title of report,” Abbrev. Name of Co., City of Co., Abbrev. State, Rep. xxx, year

- [1] \[Author(s)\], \[Title\] - Link

__Books:__

- [1] \[Author(s)\], \[Title\], \[Published\], \[Year\]

- [1] J. K. Author, “Title of chapter in the book,” in Title of His Published Book, xth ed. City of Publisher, Country if not USA: Abbrev. of Publisher, year, ch. x, sec. x, pp. xxx–xxx. 

NOTE: Use et al. when three or more names are given

e.g. 
  * [1] B. Klaus and P. Horn, Robot Vision. Cambridge, MA: MIT Press, 1986. 
  * [2] L. Stein, “Random patterns,” in Computers and You, J. S. Brake, Ed. New York: Wiley, 1994, pp. 55-70. 
  * [3] R. L. Myer, “Parametric oscillators and nonlinear materials,” in Nonlinear Optics, vol. 4, P. G. Harper and B. S. Wherret, Eds. San Francisco, CA: Academic, 1977, pp. 47-160. 
  * [4]  M. Abramowitz and I. A. Stegun, Eds., Handbook of Mathematical Functions (Applied Mathematics Series 55). Washington, DC: NBS, 1964, pp. 32-33. 

## References Within The Guide

For references to other chapters in the MSTG, simply name the chapter, e.g.: 'See also the chapter "Basic Security Testing"', etc. The MSTG should be convenenient to read as a printed book, so use internal references sparingly.

## Insert pictures

Pictures should be uploaded to the Images/Chapters directory. Afterwards they should be embedded by using the image tag, a width of 500px should be specified. For example:

```HTML
<img src="Images/Chapters/0x06d/key_hierarchy_apple.jpg" width="500px"/>
*iOS Data Protection Key Hierarchy <sup>[3]</sup>*
```

## Lowercase or capital letter after a colon

Chicago Manual of Style (6.61: Lowercase or capital letter after a colon) says: lowercase the first word unless it is a proper noun or the start of at least two complete sentences or a direct question.


## Code and Shell Commands

Use code tags when including sample code and shell commands. In Markdown, code blocks are denoted by triple backticks. GitHub also supports syntax highlighting for a variety of languages. For example, a Java code block should be annotated as follows:

\`\`\`java

public static void main(String[] args) { System.out.println(" Hello World!"); } } ;

\`\`\`

This produces the following result:

```java
public static void main(String[] args) { System.out.println(" Hello World!"); } }
```

When including shell commands, make sure to remove any host names and usernames from the command prompt, e.g.:

```
$ echo 'Hello World'
```
