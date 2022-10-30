# Pandoc Confluence Writer

Custom [Pandoc](https://pandoc.org/) writer for Confluence's
[XHTML-based storage format](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html).

## Motivation

Writing documentation in Confluence can be a slow and painful process. It would
be nice if we could simply use a Markdown file to upload to Confluence.

Confluence stores data primarily using a custom XHTML-based storage format, and
pages can be created/updated/deleted using the
[Confluence REST API](https://developer.atlassian.com/cloud/confluence/rest/v1/intro/#status-code).

Writing XHTML by hand is obviously impractical, but writing Markdown is fun.
With a way to convert from Markdown to Confluence's XHTML, we would be able to
develop another process to publish the output file to a Confluence page.

## Todo list

- [ ] Inline text
  - [x] Basic inline formatting
    - [x] Strike-through
  - [ ] Special confluence links
    - [ ] User mentions
    - [ ] JIRA link
  - [ ] Other formatting options
    - [ ] Status badge
- [ ] Block text
  - [ ] List formats
    - [ ] Task list
  - [ ] Note formats
    - [ ] Note
    - [ ] Info
    - [ ] Tip
    - [ ] Warning
  - [ ] Expandable text block
- [ ] Document organisation
  - [ ] Table of contents
    - [ ] Basic
    - [ ] With all the Confluence options
- [ ] Images
  - [x] Attached image
  - [x] External image
  - [ ] Image attributes
- [ ] Code blocks
  - [x] Simple
  - [ ] With all the Confluence options
- [ ] Character escaping
- [ ] Links
  - [ ] To another Confluence page
  - [ ] To an attachment
  - [ ] To an external site
  - [ ] To an anchor (same page)
  - [ ] With embedded image as body
  - [ ] Error on any markup not permitted in Confluence link bodies

## Dependencies

- For running the tests:
  - `npm i -g html-minifier`

## Resources

### Documentation

- [Haskell: `pandoc-types` `Text.Pandoc.Definition`](https://hackage.haskell.org/package/pandoc-types-1.22.2.1/docs/Text-Pandoc-Definition.html)
- [Pandoc: Filters](https://pandoc.org/filters.html)
- [Atlassian: Confluence Storage Format](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html)
- [Google Groups: multiple filters in Pandoc](https://groups.google.com/g/pandoc-discuss/c/vHjIOej7L0Q?pli=1)

### Similar projects

- [jpbarrette/pandoc-confluence-writer](https://github.com/jpbarrette/pandoc-confluence-writer):
  Lua filter for Confluence XHTML
