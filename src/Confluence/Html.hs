--------------------------------------------------------------------------------

module Confluence.Html (
    Element (..),
    Html,
    TagType (..),
    renderTag,
    showHtml,
) where

import Data.Text qualified as T

--------------------------------------------------------------------------------
-- Core HTML types

type Html = T.Text

type Tag = T.Text

data TagType = TagStart | TagEnd | TagStartEnd

type Attr = (T.Text, Maybe T.Text)

data Element a = Element
    { elTag :: Tag
    , elAttrs :: [Attr]
    , elBody :: [a]
    }

--------------------------------------------------------------------------------
-- Rendering a HTML element as text

-- | Returns a HTML tag text based on the tag's type, name and attributes, e.g.
-- @<ri:url ri:value=\"abc\">@ for a start tag.
renderTag :: Tag -> [Attr] -> TagType -> Html
renderTag tag_name attrs tag_ty = case tag_ty of
    TagStart -> "<" <> tagText <> ">"
    TagEnd -> "</" <> tag_name <> ">"
    TagStartEnd -> "<" <> tagText <> "/>"
  where
    tagText = T.intercalate " " $ filter (not . T.null) [tag_name, attrsText]
    attrsText =
        T.intercalate " " $
            map
                ( \(k, mv) -> case mv of
                    Nothing -> k
                    Just v -> k <> "=\"" <> v <> "\""
                )
                attrs

showHtml :: Show a => a -> Html
showHtml = T.toLower . T.pack . show

--------------------------------------------------------------------------------
