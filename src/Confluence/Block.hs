--------------------------------------------------------------------------------

module Confluence.Block (
    ToBlock (..),
    ConfluenceBlock (..),
) where

import Confluence.Html
import Confluence.Inline (ToInline (..))
import Confluence.Params (CodeBlockParams, ConfluenceParams (..))
import Confluence.Tag
import Data.Text qualified as T
import Text.Pandoc.Builder (Block (RawBlock))
import Text.Pandoc.Definition (Block (Plain))

--------------------------------------------------------------------------------
-- Instance definitions

-- | Types that can be converted to Pandoc 'Block' representation.
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
        | otherwise = mkTag TagStart <> bodyBlock <> mkTag TagEnd
      where
        bodyBlock = concatMap toBlock elBody
        mkTag = toBlock . renderTag elTag elAttrs

--------------------------------------------------------------------------------

-- | Block Confluence elements
data ConfluenceBlock
    = -- | Language, code block
      AcCodeBlock CodeBlockParams T.Text
    | -- | Type
      AcBoxedText T.Text [Block]

instance ToBlock ConfluenceBlock where
    toBlock (AcCodeBlock params code) =
        toBlock . toInline $
            acStructuredMacro
                "code"
                (acParams (toParams params) <> [acPlainTextBody code])
    toBlock (AcBoxedText box_ty bs) =
        toBlock $ acStructuredMacro box_ty [acRichTextBody bs]

--------------------------------------------------------------------------------
