--------------------------------------------------------------------------------

-- | Elements part of Confluence's XHTML-based format.
module Confluence.Element
    ( ConfluenceRi(..)
    , riInline
    ) where

import qualified Data.Text                     as T
import           Text.Pandoc.Definition         ( Inline(..) )

--------------------------------------------------------------------------------
-- Element

-- | Helper type for creating a custom HTML element (tag name; attributes).
data Element = Element
    { elTag   :: T.Text
    , elAttrs :: [(T.Text, Maybe T.Text)]
    , elBody  :: [Inline]
    }

elInline :: Element -> [Inline]
elInline Element {..}
    | null elBody = pure $ mkInline TagStartEnd
    | otherwise   = mkInline TagStart : elBody <> [mkInline TagEnd]
  where
    mkInline :: TagType -> Inline
    mkInline = RawInline "html" . renderTag elTag elAttrs


data TagType = TagStart | TagEnd | TagStartEnd

-- | Returns a HTML tag text based on the tag's type, name and attributes, e.g.
-- @<ri:url ri:value=\"abc\">@ for a start tag.
renderTag :: T.Text -> [(T.Text, Maybe T.Text)] -> TagType -> T.Text
renderTag tag_name attrs tag_ty = case tag_ty of
    TagStart    -> "<" <> tagText <> ">"
    TagEnd      -> "</" <> tag_name <> ">"
    TagStartEnd -> "<" <> tagText <> "/>"
  where
    tagText   = T.intercalate " " [tag_name, attrsText]
    attrsText = T.intercalate " " $ map
        (\(k, mv) -> case mv of
            Nothing -> k
            Just v  -> k <> "=\"" <> v <> "\""
        )
        attrs

--------------------------------------------------------------------------------
-- Confluence types

-- | Confluence resource identifier.
--
-- Resource identifiers are used to describe "links" or "references" to
-- resources in the storage format. Examples of resources include pages, blog
-- posts, comments, shortcuts, images and so forth.
--
data ConfluenceRi
    = RiAttachment T.Text
    -- ^ Attachment filename
    | RiUrl T.Text
    -- ^ URL

riInline :: ConfluenceRi -> [Inline]
riInline = elInline . riElement

riElement :: ConfluenceRi -> Element
riElement (RiAttachment fname) =
    Element "ri:attachment" [("ri:filename", Just fname)] []
riElement (RiUrl url) = Element "ri:url" [("ri:value", Just url)] []

--------------------------------------------------------------------------------
