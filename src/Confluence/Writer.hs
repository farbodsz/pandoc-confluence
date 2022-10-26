--------------------------------------------------------------------------------

module Confluence.Writer
    ( inlineFilter
    ) where

import           Confluence.Element
import qualified Data.Text                     as T
import           Text.Pandoc.Definition

--------------------------------------------------------------------------------

-- | Inlines in Confluence XHTML are rendered differently to Pandoc's default
-- HTML output. These are:
--
--   * Strikethroughs: @span@ with @text-decoration@ instead of the @del@ tag
--
--     > <span style="text-decoration: line-through;">foo bar</span>
--
inlineFilter :: Inline -> [Inline]
inlineFilter (Strikeout inlines) = pure $ Span attrs inlines
    where attrs = ("", [], [("style", "text-decoration: line-through;")])
inlineFilter (Image _ _ (url, _)) =
    toInline . AcImage $ if "http" `T.isPrefixOf` url
        then toInline $ RiAttachment url
        else toInline $ RiUrl url
inlineFilter i = pure i

--------------------------------------------------------------------------------
