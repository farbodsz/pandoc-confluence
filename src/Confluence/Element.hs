--------------------------------------------------------------------------------

-- | Elements part of Confluence's XHTML-based format.
module Confluence.Element
    ( ToInline(..)
    , ConfluenceRi(..)
    , ConfluenceInline(..)
    ) where

import           Confluence.Html
import           Confluence.Tag
import qualified Data.Text                     as T
import           Text.Pandoc.Definition         ( Inline(RawInline) )

--------------------------------------------------------------------------------
-- Confluence elements

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

instance ToInline ConfluenceRi where
    toInline (RiAttachment fname) = toInline $ riAttachment fname
    toInline (RiUrl        url  ) = toInline $ riUrl url


-- | Inline Confluence elements
data ConfluenceInline = AcImage [Inline]

instance ToInline ConfluenceInline where
    toInline (AcImage is) = toInline $ Element "ac:image" [] is

--------------------------------------------------------------------------------
-- Instance definitions

class ToInline a where
    toInline :: a -> [Inline]

instance ToInline Inline where
    toInline = pure

instance ToInline Html where
    toInline = pure . RawInline "html"

instance ToInline a => ToInline (Element a) where
    toInline Element {..} = if null elBody
        then mkTag TagStartEnd
        else
            let inlines = concatMap toInline elBody
            in  mkTag TagStart <> inlines <> mkTag TagEnd
      where
        mkTag :: TagType -> [Inline]
        mkTag = toInline . renderTag elTag elAttrs


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

instance ToInline ConfluenceRi where
    toInline (RiAttachment fname) =
        toInline $ htmlTag "ri:attachment" ! ("ri:filename", Just fname)
    toInline (RiUrl url) = toInline $ htmlTag "ri:url" ! ("ri:value", Just url)


-- | Inline Confluence elements
data ConfluenceInline = AcImage [Inline]

instance ToInline ConfluenceInline where
    toInline (AcImage is) = toInline $ Element "ac:image" [] is

--------------------------------------------------------------------------------
