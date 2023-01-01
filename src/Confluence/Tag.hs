--------------------------------------------------------------------------------

-- | Confluence-specific XHTML tags.
module Confluence.Tag (
    acImage,
    acStructuredMacro,
    acParam,
    acParams,
    acPlainTextBody,
    acRichTextBody,
    riAttachment,
    riUrl,
) where

import Confluence.Html (Element (..))
import Data.Text qualified as T

--------------------------------------------------------------------------------

-- | A Confluence image element with no attributes.
acImage :: [a] -> Element a
acImage = Element "ac:image" []

-- | @acStructuredMacro macroName@ creates a set of nested Confluence elements
-- representing a Structured Macro with the provided name.
acStructuredMacro :: T.Text -> [a] -> Element a
acStructuredMacro name =
    Element
        "ac:structured-macro"
        [("ac:name", Just name), ("ac:schema-version", Just "1")]

-- | @acParam name value@ makes an @ac:parameter@ Confluence element based on
-- the given parameter name and value.
acParam :: T.Text -> T.Text -> Element T.Text
acParam name value = Element "ac:parameter" [("ac:name", Just name)] [value]

-- | Like 'acParam' but for multiple key-value pairs.
acParams :: [(T.Text, T.Text)] -> [Element T.Text]
acParams = map (uncurry acParam)

-- | @acPlainTextBody text@ produces a Confluence plain text body element with
-- that text.
acPlainTextBody :: T.Text -> Element T.Text
acPlainTextBody txt = Element "ac:plain-text-body" [] ["<![CDATA[", txt, "]]>"]

acRichTextBody :: [a] -> Element a
acRichTextBody = Element "ac:rich-text-body" []

-- | @riAttachment filename@ transforms a filename to a Confluence attachment
-- element with that filename.
riAttachment :: T.Text -> Element T.Text
riAttachment fname = Element "ri:attachment" [("ri:filename", Just fname)] []

-- | @riUrl url@ transforms a URL to a Confluence URL element referencing that
-- URL.
riUrl :: T.Text -> Element T.Text
riUrl url = Element "ri:url" [("ri:value", Just url)] []

--------------------------------------------------------------------------------
