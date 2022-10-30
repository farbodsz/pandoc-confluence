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
data ConfluenceBlock
    = AcCodeBlock T.Text T.Text
    -- ^ Language, code block
    | AcBoxedText T.Text [Block]
    -- ^ Type

instance ToBlock ConfluenceBlock where
    toBlock (AcCodeBlock lang code) = toBlock . toInline $ acStructuredMacro
        "code"
        [acParameter "language" lang, acPlainTextBody code]
    toBlock (AcBoxedText box_ty bs) =
        toBlock $ acStructuredMacro box_ty [acRichTextBody bs]

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


class ToBlock a where
    toBlock :: a -> [Block]

instance ToBlock Block where
    toBlock = pure

instance ToBlock Html where
    toBlock = pure . RawBlock "html"

instance ToInline a => ToBlock [a] where
    toBlock = pure . Plain . concatMap toInline

instance ToBlock a => ToBlock (Element a) where
    toBlock Element {..}
        | null elBody = mkTag TagStartEnd
        | otherwise   = mkTag TagStart <> bodyBlock <> mkTag TagEnd
      where
        bodyBlock = concatMap toBlock elBody
        mkTag     = toBlock . renderTag elTag elAttrs

--------------------------------------------------------------------------------
