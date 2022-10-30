--------------------------------------------------------------------------------

-- | Confluence-specific XHTML tags.
--
module Confluence.Tag
    ( acStructuredMacro
    , acParameter
    , acPlainTextBody
    , riAttachment
    , riUrl
    ) where

import           Confluence.Html                ( Element(..) )
import qualified Data.Text                     as T

--------------------------------------------------------------------------------

acStructuredMacro :: T.Text -> [a] -> Element a
acStructuredMacro name = Element
    "ac:structured-macro"
    [("ac:name", Just name), ("ac:schema-version", Just "1")]

acParameter :: T.Text -> T.Text -> Element T.Text
acParameter name value =
    Element "ac:parameter" [("ac:name", Just name)] [value]

acPlainTextBody :: T.Text -> Element T.Text
acPlainTextBody txt = Element "ac:plain-text-body" [] ["<![CDATA[", txt, "]]>"]

riAttachment :: T.Text -> Element T.Text
riAttachment fname = Element "ri:attachment" [("ri:filename", Just fname)] []

riUrl :: T.Text -> Element T.Text
riUrl url = Element "ri:url" [("ri:value", Just url)] []

--------------------------------------------------------------------------------
