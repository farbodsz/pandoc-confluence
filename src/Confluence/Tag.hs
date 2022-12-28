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

acImage :: [a] -> Element a
acImage = Element "ac:image" []

acStructuredMacro :: T.Text -> [a] -> Element a
acStructuredMacro name =
    Element
        "ac:structured-macro"
        [("ac:name", Just name), ("ac:schema-version", Just "1")]

acParam :: T.Text -> T.Text -> Element T.Text
acParam name value = Element "ac:parameter" [("ac:name", Just name)] [value]

acParams :: [(T.Text, T.Text)] -> [Element T.Text]
acParams = map (uncurry acParam)

acPlainTextBody :: T.Text -> Element T.Text
acPlainTextBody txt = Element "ac:plain-text-body" [] ["<![CDATA[", txt, "]]>"]

acRichTextBody :: [a] -> Element a
acRichTextBody = Element "ac:rich-text-body" []

riAttachment :: T.Text -> Element T.Text
riAttachment fname = Element "ri:attachment" [("ri:filename", Just fname)] []

riUrl :: T.Text -> Element T.Text
riUrl url = Element "ri:url" [("ri:value", Just url)] []

--------------------------------------------------------------------------------
