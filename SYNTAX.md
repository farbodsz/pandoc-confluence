# Syntax

The file format accepted by this filter (which we'll call Confluence Markdown)
is a **subset of
[Pandoc Markdown](https://pandoc.org/MANUAL.html#pandocs-markdown)**.

So all Pandoc Markdown syntax is valid.

To this, we add/modify:

## Boxed text

To render boxed text, such as a "note", "info", "tip" or "warning", write a

- Blockquote
- with the type of box as the first word (case insensitive)
- followed by colon and space

Examples:

```markdown
> Tip: Write boxed text with a blockquote, and the type of box as the start.
>
> Boxed text can be multiple paragraphs long.
```

```markdown
> WARNING: This is a warning.
```

## Confluence macros

Any inline Confluence macro can be written using curly brace syntax:

```markdown
{macroName:key1=value1|key2=value2|keyN=valueN}
```

Just like in the Confluence Wiki file format.

For example, to render a table of contents macro, with some options:

```markdown
{toc:printable=true|outline=true}
```
