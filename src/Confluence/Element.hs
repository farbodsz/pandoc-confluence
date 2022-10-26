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
    }

elInline :: Element -> [Inline]
elInline Element {..} = pure $ RawInline "html" $ T.concat
    ["<" <> T.intercalate " " [elTag, htmlKvs] <> "/>"]
  where
    htmlKvs = T.intercalate " " $ fmap
        (\(k, mv) -> case mv of
            Nothing -> k
            Just v  -> k <> "=\"" <> v <> "\""
        )
        elAttrs

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

-- | Outputs a Confluence resource as a list of inlines.
riInline :: ConfluenceRi -> [Inline]
riInline = elInline . riElement

-- | Element representation of a Confluence resource identifier.
riElement :: ConfluenceRi -> Element
riElement (RiAttachment fname) =
    Element "ri:attachment" [("ri:filename", Just fname)]
riElement (RiUrl url) = Element "ri:url" [("ri:value", Just url)]

--------------------------------------------------------------------------------
