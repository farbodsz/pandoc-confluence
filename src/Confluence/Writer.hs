--------------------------------------------------------------------------------

module Confluence.Writer
    ( inlineFilter
    ) where

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
inlineFilter (Image _ _ (url, _)) = withinTag "ac:image"
                                              (mkInlineHtml innerHtml)
  where
    innerHtml = if "http" `T.isPrefixOf` url
        then T.concat ["<ri:attachment ri:filename=\"", url, "\"/>"]
        else T.concat ["<ri:url ri:value=\"", url, "\"/>"]
inlineFilter i = pure i

--------------------------------------------------------------------------------

withinTag :: T.Text -> Inline -> [Inline]
withinTag tag inner =
    [mkInlineHtml ("<" <> tag <> ">"), inner, mkInlineHtml ("</" <> tag <> ">")]

mkInlineHtml :: T.Text -> Inline
mkInlineHtml = RawInline "html"

--------------------------------------------------------------------------------
