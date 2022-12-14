--------------------------------------------------------------------------------

-- | Inline Confluence elements.
module Confluence.Inline (
    ToInline (..),
    ConfluenceInline (..),
    MacroName,
    MacroOption,
) where

import Confluence.Html
import Confluence.Tag
import Data.Text qualified as T
import Text.Pandoc.Definition (Inline (RawInline))

--------------------------------------------------------------------------------
-- Instance definitions

-- | Types that can be converted to Pandoc 'Inline' representation.
class ToInline a where
    toInline :: a -> [Inline]

instance ToInline Inline where
    toInline = pure

instance ToInline Html where
    toInline = pure . RawInline "html"

instance ToInline a => ToInline (Element a) where
    toInline Element {..}
        | null elBody = mkTag TagStartEnd
        | otherwise = mkTag TagStart <> inlines <> mkTag TagEnd
      where
        inlines = concatMap toInline elBody
        mkTag = toInline . renderTag elTag elAttrs

--------------------------------------------------------------------------------

type MacroName = T.Text

-- | A macro option is a key-value mapping, written in source code as:
-- @key=value@ where both key and value are (unquoted) strings.
type MacroOption = (T.Text, T.Text)

-- | Inline Confluence elements, including Confluence resource identifiers.
--
-- Resource identifiers are used to describe "links" or "references" to
-- resources in the storage format. Examples of resources include pages, blog
-- posts, comments, shortcuts, images and so forth.
data ConfluenceInline
    = -- | Attachment filename
      RiAttachment T.Text
    | -- | URL
      RiUrl T.Text
    | -- | Image (alt text inlines)
      AcImage [Inline]
    | -- | Some other inline macro.
      AcMacro MacroName [MacroOption]

instance ToInline ConfluenceInline where
    toInline (RiAttachment fname) = toInline $ riAttachment fname
    toInline (RiUrl url) = toInline $ riUrl url
    toInline (AcImage is) = toInline $ acImage is
    toInline (AcMacro name opts) =
        toInline $ acStructuredMacro name (acParams opts)

--------------------------------------------------------------------------------
