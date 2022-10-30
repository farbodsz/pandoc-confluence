--------------------------------------------------------------------------------

module Confluence.Writer
    ( blockFilter
    , inlineFilter
    ) where

import           Confluence.Element
import qualified Data.Text                     as T
import           Text.Pandoc.Definition

--------------------------------------------------------------------------------

-- | @blockFilter block@ transforms a Pandoc 'Block' into an equivalent
-- Confluence XHTML representation (a 'Block').
--
-- Examples of Confluence XHTML blocks, which differ from Pandoc's default HTML
-- output, are:
--
--   * Code blocks: rendered with the @ac:structured-macro@ tag
--
blockFilter :: Block -> [Block]
blockFilter (CodeBlock _attrs txt) = toBlock $ AcCodeBlock "bash" txt
blockFilter b                      = pure b


-- | @inlineFilter inline@ transforms a Pandoc 'Inline' into an equivalent
-- Confluence XHTML representation (as a list of 'Inline's).
--
-- Examples of Confluence XHTML inlines, which differ from Pandoc's default HTML
-- output, are:
--
--   * Strikethroughs: rendered as @span@s
--   * Images: rendered with @ac:image@
--
inlineFilter :: Inline -> [Inline]
inlineFilter (Strikeout inlines) = pure $ Span attrs inlines
    where attrs = ("", [], [("style", "text-decoration: line-through;")])
inlineFilter (Image _ _ (url, _)) =
    toInline . AcImage . toInline $ if "http" `T.isPrefixOf` url
        then RiUrl url
        else RiAttachment url
inlineFilter i = pure i

--------------------------------------------------------------------------------
