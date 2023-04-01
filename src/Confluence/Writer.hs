--------------------------------------------------------------------------------

module Confluence.Writer (
    blockFilter,
    inlineFilter,
) where

import Confluence.Block
import Confluence.Inline
import Confluence.Params
import Control.Monad (liftM2, mfilter)
import Data.Bifunctor (Bifunctor (first))
import Data.Text qualified as T
import Data.Void (Void)
import Text.Megaparsec (Parsec, option, parseMaybe, sepBy1, some, (<|>))
import Text.Megaparsec.Char (char, digitChar, letterChar, spaceChar, upperChar)
import Text.Pandoc.Definition

--------------------------------------------------------------------------------

-- | @blockFilter block@ transforms a Pandoc 'Block' into an equivalent
-- Confluence XHTML representation (a 'Block').
--
-- A code block is only transformed if it is marked with a valid programming
-- language, otherwise the block is rendered as normal.
--
-- If a macro is the only inline in a block, then it is rendered as a plain
-- block with that single inline.
blockFilter :: Block -> [Block]
blockFilter b@(CodeBlock attrs body) = case getCodeBlockLang attrs of
    Nothing -> pure b
    Just lang ->
        toBlock $
            AcCodeBlock
                (CodeBlockParams lang Nothing Nothing Nothing Nothing Nothing)
                body
blockFilter (BlockQuote (b : bs)) =
    let (m_box_ty, rest_b) =
            first
                (mfilter isValidBoxTy . fmap extractTag)
                (splitBlockOnFirstStr b)
     in case m_box_ty of
            Nothing -> b : bs
            Just box_ty -> toBlock $ AcBoxedText box_ty (rest_b : bs)
  where
    extractTag = T.toLower . T.strip . head . T.split (== ':')
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
-- We also add the option of including Confluence Wiki-like inline macros, so
-- any string surrounded by curly braces is assumed to be a macro.
inlineFilter :: Inline -> [Inline]
inlineFilter (Str txt) = case parseJira txt of
    Just code -> toInline $ RiShortcut "jira" code
    Nothing -> case parseMacro txt of
        Nothing -> pure $ Str txt
        Just (name, opts) -> toInline $ AcMacro name opts
inlineFilter (Strikeout inlines) = pure $ Span attrs inlines
  where
    attrs = ("", [], [("style", "text-decoration: line-through;")])
inlineFilter (Image _ _ (url, _)) =
    toInline . AcImage . toInline $
        if "http" `T.isPrefixOf` url
            then RiUrl url
            else RiAttachment url
inlineFilter i = pure i

--------------------------------------------------------------------------------

-- | @splitBlockOnFirstStr block@ returns the first string of a block, followed
-- by the rest of the block (i.e. block, excluding this first string).
splitBlockOnFirstStr :: Block -> (Maybe T.Text, Block)
splitBlockOnFirstStr (Plain ((Str t) : is)) = (Just t, Plain is)
splitBlockOnFirstStr (Para ((Str t) : is)) = (Just t, Para is)
splitBlockOnFirstStr (LineBlock (((Str t) : is) : iss)) =
    (Just t, LineBlock (is : iss))
splitBlockOnFirstStr b = (Nothing, b)

-- | @getCodeBlockLang attributes@ returns the language string if it is the only
-- class in the code block's attributes.
getCodeBlockLang :: Attr -> Maybe T.Text
getCodeBlockLang (_, [cls], _) = Just cls
getCodeBlockLang (_, _, _) = Nothing

--------------------------------------------------------------------------------

type ConfluenceMdParser = Parsec Void T.Text

-- | @parseMacro text@ attempts to parse an inline string representing a
-- Confluence macro into a Confluence macro.
--
-- Inline Confluence macros use the following syntax:
-- @
-- {macroName:key1=value1|key2=value2|keyN=valueN}
-- @
--
-- Examples:
--
-- >>> parseMacro "{toc}"
-- Just ("toc",[])
--
-- >>> parseMacro "{toc:printable=true|outline=true}"
-- Just ("toc",[("printable","true"),("outline","true")])
--
-- >>> parseMacro "{status:colour=Blue|title=In progress}"
-- Just ("status",[("colour","Blue"),("title","In progress")])
--
-- >>> parseMacro "not a macro"
-- Nothing
parseMacro :: T.Text -> Maybe (MacroName, [MacroOption])
parseMacro = parseMaybe parser
  where
    parser = do
        _ <- char '{'
        name <- keyP
        opts <- option mempty $ char ':' *> (macroOptP `sepBy1` char '|')
        _ <- char '}'
        pure (name, opts)

    keyP :: ConfluenceMdParser T.Text
    keyP = T.pack <$> some letterChar

    valueP :: ConfluenceMdParser T.Text
    valueP = T.pack <$> some (letterChar <|> spaceChar)

    macroOptP :: ConfluenceMdParser MacroOption
    macroOptP = liftM2 (,) keyP (char '=' *> valueP)

-- | @parseJira text@ attempts to parse a string representing a jira identifier.
--
-- Examples:
--
-- >>> parseJira "ABC-123"
-- Just "ABC-123"
--
-- >>> parseJira "abc-123"
-- Nothing
--
-- >>> parseJira "ABC-1foobar"
-- Nothing
parseJira :: T.Text -> Maybe T.Text
parseJira = parseMaybe parser
  where
    parser :: ConfluenceMdParser T.Text
    parser = do
        spaceKey <- T.pack <$> some upperChar
        _ <- char '-'
        number <- T.pack <$> some digitChar
        pure $ spaceKey <> "-" <> number

--------------------------------------------------------------------------------
