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
