--------------------------------------------------------------------------------

-- | Inline Confluence elements.
module Confluence.Inline
    ( ToInline(..)
    , ConfluenceInline(..)
    ) where

import           Confluence.Html
import           Confluence.Tag
import qualified Data.Text                     as T
import           Text.Pandoc.Definition         ( Inline(RawInline) )

--------------------------------------------------------------------------------
-- Instance definitions

class ToInline a where
    toInline :: a -> [Inline]

instance ToInline Inline where
    toInline = pure

instance ToInline Html where
    toInline = pure . RawInline "html"

instance ToInline a => ToInline (Element a) where
    toInline Element {..}
        | null elBody = mkTag TagStartEnd
        | otherwise   = mkTag TagStart <> inlines <> mkTag TagEnd
      where
        inlines = concatMap toInline elBody
        mkTag   = toInline . renderTag elTag elAttrs

--------------------------------------------------------------------------------

-- | Inline Confluence elements, including Confluence resource identifiers.
--
-- Resource identifiers are used to describe "links" or "references" to
-- resources in the storage format. Examples of resources include pages, blog
-- posts, comments, shortcuts, images and so forth.
--
data ConfluenceInline
    = RiAttachment T.Text
    -- ^ Attachment filename
    | RiUrl T.Text
    -- ^ URL
    | AcImage [Inline]

instance ToInline ConfluenceInline where
    toInline (RiAttachment fname) = toInline $ riAttachment fname
    toInline (RiUrl        url  ) = toInline $ riUrl url
    toInline (AcImage      is   ) = toInline $ acImage is

--------------------------------------------------------------------------------
