--------------------------------------------------------------------------------

module Confluence.Block
    ( ToBlock(..)
    , ConfluenceBlock(..)
    ) where

import           Confluence.Html
import           Confluence.Inline              ( ToInline(..) )
import           Confluence.Tag
import qualified Data.Text                     as T
import           Text.Pandoc.Builder            ( Block(RawBlock) )
import           Text.Pandoc.Definition         ( Block(Plain) )

--------------------------------------------------------------------------------
-- Instance definitions

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

-- | Block Confluence elements
data ConfluenceBlock
    = AcCodeBlock T.Text T.Text
    -- ^ Language, code block
    | AcBoxedText T.Text [Block]
    -- ^ Type

instance ToBlock ConfluenceBlock where
    toBlock (AcCodeBlock lang code) = toBlock . toInline $ acStructuredMacro
        "code"
        [acParam "language" lang, acPlainTextBody code]
    toBlock (AcBoxedText box_ty bs) =
        toBlock $ acStructuredMacro box_ty [acRichTextBody bs]

--------------------------------------------------------------------------------
