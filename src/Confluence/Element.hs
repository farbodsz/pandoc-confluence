--------------------------------------------------------------------------------

-- | Elements part of Confluence's XHTML-based format.
module Confluence.Element
    ( ToInline(..)
    , ToBlock(..)
    , ConfluenceRi(..)
    , ConfluenceInline(..)
    , ConfluenceBlock(..)
    ) where

import           Confluence.Html
import           Confluence.Tag
import qualified Data.Text                     as T
import           Text.Pandoc.Definition         ( Block(Plain, RawBlock)
                                                , Inline(RawInline)
                                                )

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


-- | Block Confluence elements
data ConfluenceBlock = AcCodeBlock T.Text T.Text
    -- ^ Language, code block

instance ToBlock ConfluenceBlock where
    toBlock (AcCodeBlock lang code) = toBlock . toInline $ acStructuredMacro
        "code"
        [acParameter "language" lang, acPlainTextBody code]

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


class ToBlock a where
    toBlock :: a -> Block

instance ToBlock Block where
    toBlock = id

instance ToBlock Html where
    toBlock = RawBlock "html"

instance ToInline a => ToBlock [a] where
    toBlock es = Plain $ concatMap toInline es

--------------------------------------------------------------------------------
