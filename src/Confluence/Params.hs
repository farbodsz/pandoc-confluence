--------------------------------------------------------------------------------

-- | Parameters to Confluence AC objects.
module Confluence.Params where

import Confluence.Html (showHtml)
import Data.Maybe (mapMaybe)
import Data.Text qualified as T

--------------------------------------------------------------------------------

class ConfluenceParams a where
    toParams :: a -> [(T.Text, T.Text)]

-- | Parameters for a Code Block macro.
--
-- See: https://confluence.atlassian.com/doc/code-block-macro-139390.html
data CodeBlockParams = CodeBlockParams
    { acCodeLang :: T.Text
    , acCodeTitle :: Maybe T.Text
    , acCodeCollapsible :: Maybe Bool
    , acCodeShowLineNums :: Maybe Bool
    , acCodeFirstLine :: Maybe Int
    , acCodeTheme :: Maybe T.Text
    }

instance ConfluenceParams CodeBlockParams where
    toParams CodeBlockParams {..} =
        mapMaybe
            sequenceA
            [ ("language", Just acCodeLang)
            , ("title", acCodeTitle)
            , ("collapse", showHtml <$> acCodeCollapsible)
            , ("linenumbers", showHtml <$> acCodeShowLineNums)
            , ("firstline", showHtml <$> acCodeFirstLine)
            , ("theme", showHtml <$> acCodeTheme)
            ]

--------------------------------------------------------------------------------
