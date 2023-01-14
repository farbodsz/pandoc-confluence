<h1>Pandoc Confluence Writer</h1>

Custom [Pandoc](https://pandoc.org/) writer for Confluence's
[XHTML-based storage format](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html).

<a href="https://www.repostatus.org/#wip"><img src="https://www.repostatus.org/badges/latest/wip.svg" alt="Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public." /></a>

<!-- NOTE: run doctoc on this document to generate contents page -->
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Motivation](#motivation)
- [Features](#features)
- [Installation](#installation)
- [Contributing](#contributing)
  - [Setting up development environment](#setting-up-development-environment)
  - [Testing](#testing)
- [Resources](#resources)
  - [Documentation](#documentation)
  - [Similar projects](#similar-projects)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Motivation

Writing documentation in Confluence can be a slow and painful process. It would
be nice if we could simply use a Markdown file to upload to Confluence.

Confluence stores data primarily using a custom XHTML-based storage format, and
pages can be created/updated/deleted using the
[Confluence REST API](https://developer.atlassian.com/cloud/confluence/rest/v1/intro/#status-code).

Writing XHTML by hand is obviously impractical, but writing Markdown is fun.
With a way to convert from Markdown to Confluence's XHTML, we would be able to
develop another process to publish the output file to a Confluence page.

## Features

- Inline text
  - [x] Standard formatting (bold/italic)
  - [ ] JIRAs
  - [ ] User mentions
- Block text
  - [x] Note/info/tip/warning boxes
  - [ ] Expandable text block
  - [x] Confluence macros (status badge, table of contents,
        [cheese](https://confluence.atlassian.com/doc/cheese-macro-154632825.html))
  - [x] Standard code blocks
  - [ ] Code blocks with custom options
- Images
  - [ ] Images
  - [ ] Image attributes
- Links
  - [ ] To another Confluence page
  - [ ] To an attachment
  - [ ] To an external site
  - [ ] To an anchor (same page)
  - [ ] With embedded image as body
  - [ ] Error on any markup not permitted in Confluence link bodies

See [SYNTAX](./SYNTAX.md) for how to represent these in "Confluence markdown".

## Installation

Install from source:

```sh
$ stack install
```

Installation from static binary coming soon! (TODO)

## Contributing

### Setting up development environment

If you don't already have Haskell installed, the best way to install it is via
[GHCup](https://www.haskell.org/ghcup/).

### Testing

To run the end-to-end tests, you need to install the following dependencies:

```sh
$ npm i -g html-minifier
```

Run tests via `make`:

```sh
$ make test         # run end-to-end tests
$ make doctest      # test examples in doc comments
$ make test-all     # run all tests
```

## Resources

### Documentation

- Atlassian:
  - [Atlassian: Confluence Storage Format](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html)
  - [Atlassian: Confluence Macros](https://confluence.atlassian.com/doc/macros-139387.html)
- Haskell:
  - [Hackage: `pandoc-types` `Text.Pandoc.Definition`](https://hackage.haskell.org/package/pandoc-types-1.22.2.1/docs/Text-Pandoc-Definition.html)
  - [Pandoc: Filters](https://pandoc.org/filters.html)
- Forums:
  - [Google Groups: multiple filters in Pandoc](https://groups.google.com/g/pandoc-discuss/c/vHjIOej7L0Q?pli=1)

### Similar projects

- Atlassian Marketplace:
  - [Markdown Extensions for Confluence](https://marketplace.atlassian.com/apps/1215703/markdown-extensions-for-confluence?hosting=server&tab=overview)
  - [Source Editor for Confluence](https://marketplace.atlassian.com/apps/1215664/source-editor-for-confluence?hosting=datacenter&tab=overview)
- Pandoc Filters:
  - [jpbarrette/pandoc-confluence-writer](https://github.com/jpbarrette/pandoc-confluence-writer):
    Lua filter for Confluence XHTML
