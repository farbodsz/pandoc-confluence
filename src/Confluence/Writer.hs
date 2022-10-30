--------------------------------------------------------------------------------

module Confluence.Writer
    ( blockFilter
    , inlineFilter
    ) where

import           Confluence.Block
import           Confluence.Inline
import           Control.Monad                  ( mfilter )
import           Data.Bifunctor                 ( Bifunctor(first) )
import qualified Data.Text                     as T
import           Text.Pandoc.Definition

--------------------------------------------------------------------------------

-- | @blockFilter block@ transforms a Pandoc 'Block' into an equivalent
-- Confluence XHTML representation (a 'Block').
--
-- Examples of Confluence XHTML blocks, which differ from Pandoc's default HTML
-- output, are:
--
--   * Code blocks: rendered with the @ac:structured-macro@ tag
--
blockFilter :: Block -> [Block]
blockFilter (CodeBlock _attrs txt) = toBlock $ AcCodeBlock "bash" txt
blockFilter (BlockQuote (b : bs)) =
    let (m_box_ty, rest_b) = first (mfilter isValidBoxTy . fmap extractTag)
                                   (splitBlockOnFirstStr b)
    in  case m_box_ty of
            Nothing     -> b : bs
            Just box_ty -> toBlock $ AcBoxedText box_ty (rest_b : bs)
  where
    extractTag   = T.toLower . T.strip . head . T.split (== ':')
    isValidBoxTy = flip elem ["note", "info", "tip", "warning"]

blockFilter b = pure b


-- | @inlineFilter inline@ transforms a Pandoc 'Inline' into an equivalent
-- Confluence XHTML representation (as a list of 'Inline's).
--
-- Examples of Confluence XHTML inlines, which differ from Pandoc's default HTML
-- output, are:
--
--   * Strikethroughs: rendered as @span@s
--   * Images: rendered with @ac:image@
--
inlineFilter :: Inline -> [Inline]
inlineFilter (Strikeout inlines) = pure $ Span attrs inlines
    where attrs = ("", [], [("style", "text-decoration: line-through;")])
inlineFilter (Image _ _ (url, _)) =
    toInline . AcImage . toInline $ if "http" `T.isPrefixOf` url
        then RiUrl url
        else RiAttachment url
inlineFilter i = pure i

--------------------------------------------------------------------------------

-- | @splitBlockOnFirstStr block@ returns a the first string of a block,
-- followed by the rest of the block (i.e. block, excluding this first string).
splitBlockOnFirstStr :: Block -> (Maybe T.Text, Block)
splitBlockOnFirstStr (Plain ((Str t) : is)) = (Just t, Plain is)
splitBlockOnFirstStr (Para  ((Str t) : is)) = (Just t, Para is)
splitBlockOnFirstStr (LineBlock (((Str t) : is) : iss)) =
    (Just t, LineBlock (is : iss))
splitBlockOnFirstStr b = (Nothing, b)

--------------------------------------------------------------------------------
