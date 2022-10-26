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
inlineFilter (Image _ _ (url, _)) = withinTag "ac:image" innerInline
  where
    innerInline = if "http" `T.isPrefixOf` url
        then riInline $ RiAttachment url
        else riInline $ RiUrl url
inlineFilter i = pure i

withinTag :: T.Text -> [Inline] -> [Inline]
withinTag tag inlines = concat
    [ [RawInline "html" ("<" <> tag <> ">")]
    , inlines
    , [RawInline "html" ("</" <> tag <> ">")]
    ]

--------------------------------------------------------------------------------
