--------------------------------------------------------------------------------

module Confluence.Writer
    ( inlineFilter
    ) where

import           Text.Pandoc.Definition

--------------------------------------------------------------------------------

-- | Inlines in Confluence XHTML are rendered differently to Pandoc's default
-- HTML output. These are:
--
--   * Strikethroughs: @span@ with @text-decoration@ instead of the @del@ tag
--
--     > <span style="text-decoration: line-through;">foo bar</span>
--
inlineFilter :: Inline -> IO Inline
inlineFilter (Strikeout inlines) = pure $ Span attrs inlines
    where attrs = ("", [], [("style", "text-decoration: line-through;")])
inlineFilter i = pure i

--------------------------------------------------------------------------------
