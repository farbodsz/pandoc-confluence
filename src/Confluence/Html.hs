--------------------------------------------------------------------------------

module Confluence.Html
    ( Element(..)
    -- * HTML types
    , Html
    , ToHtml(..)
    , TagType(..)
    -- * Utilities to make Elements
    , tag
    , htmlTag
    , (!)
    -- * Rendering functions
    , renderTag
    ) where

import qualified Data.Text                     as T

--------------------------------------------------------------------------------
-- Core HTML types

type Html = T.Text

type Tag = T.Text

data TagType = TagStart | TagEnd | TagStartEnd

type Attr = (T.Text, Maybe T.Text)

data Element a = Element
    { elTag   :: Tag
    , elAttrs :: [Attr]
    , elBody  :: [a]
    }

--------------------------------------------------------------------------------
-- Utility functions to create Elements (inspired by blaze-markup)

tag :: Tag -> Element a
tag t = Element t mempty mempty

htmlTag :: Tag -> Element Html
htmlTag t = Element t mempty mempty

(!) :: Element a -> Attr -> Element a
(!) Element {..} attr = Element elTag (attr : elAttrs) elBody

--------------------------------------------------------------------------------
-- Rendering a HTML element as text

class ToHtml a where
    toHtml :: a -> Html

instance (ToHtml a) => ToHtml (Element a) where
    toHtml Element {..}
        | null elBody = renderTag elTag elAttrs TagStartEnd
        | otherwise = T.concat
            [ renderTag elTag elAttrs TagStart
            , T.concat $ toHtml <$> elBody
            , renderTag elTag elAttrs TagEnd
            ]

-- | Returns a HTML tag text based on the tag's type, name and attributes, e.g.
-- @<ri:url ri:value=\"abc\">@ for a start tag.
renderTag :: Tag -> [Attr] -> TagType -> Html
renderTag tag_name attrs tag_ty = case tag_ty of
    TagStart    -> "<" <> tagText <> ">"
    TagEnd      -> "</" <> tag_name <> ">"
    TagStartEnd -> "<" <> tagText <> "/>"
  where
    tagText   = T.intercalate " " $ filter (not . T.null) [tag_name, attrsText]
    attrsText = T.intercalate " " $ map
        (\(k, mv) -> case mv of
            Nothing -> k
            Just v  -> k <> "=\"" <> v <> "\""
        )
        attrs

--------------------------------------------------------------------------------
