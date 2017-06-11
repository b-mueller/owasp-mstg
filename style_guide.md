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

Papers:

- [1] \[Author(s)\], \[Title\] - Link

Books:

- [1] \[Author(s)\], \[Title\], \[Published\], \[Year\]

## References Within The Guide

For references to other chapters in the MSTG, simply name the chapter, e.g.: 'See also the chapter "Basic Security Testing"', etc. The MSTG should be convenenient to read as a printed book, so use internal references sparingly.

## Insert pictures

Pictures should be uploaded to the Images/Chapters directory. Afterwards they should be embedded by using the image tag, a width of 500px should be specified. For example:

```HTML
<img src="Images/Chapters/0x06d/key_hierarchy_apple.jpg" width="500px"/>
*iOS Data Protection Key Hierarchy <sup>[3]</sup>*
```

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
