--------------------------------------------------------------------------------

module Confluence.Writer
    ( blockFilter
    , inlineFilter
    ) where

import           Confluence.Block
import           Confluence.Inline
import           Confluence.Params
import           Control.Monad                  ( mfilter )
import           Data.Bifunctor                 ( Bifunctor(first, second) )
import qualified Data.Text                     as T
import           Text.Pandoc.Definition

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
    Nothing   -> pure b
    Just lang -> toBlock $ AcCodeBlock
        (CodeBlockParams lang Nothing Nothing Nothing Nothing Nothing)
        body
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
-- We also add the option of including Confluence Wiki-like inline macros, so
-- any string surrounded by curly braces is assumed to be a macro.
--
inlineFilter :: Inline -> [Inline]
inlineFilter (Str txt)
    | isMacroFormat txt = toInline . uncurry AcMacro $ parseMacro txt
    | otherwise         = pure $ Str txt
inlineFilter (Strikeout inlines) = pure $ Span attrs inlines
    where attrs = ("", [], [("style", "text-decoration: line-through;")])
inlineFilter (Image _ _ (url, _)) =
    toInline . AcImage . toInline $ if "http" `T.isPrefixOf` url
        then RiUrl url
        else RiAttachment url
inlineFilter i = pure i

--------------------------------------------------------------------------------

-- | @splitBlockOnFirstStr block@ returns the first string of a block, followed
-- by the rest of the block (i.e. block, excluding this first string).
splitBlockOnFirstStr :: Block -> (Maybe T.Text, Block)
splitBlockOnFirstStr (Plain ((Str t) : is)) = (Just t, Plain is)
splitBlockOnFirstStr (Para  ((Str t) : is)) = (Just t, Para is)
splitBlockOnFirstStr (LineBlock (((Str t) : is) : iss)) =
    (Just t, LineBlock (is : iss))
splitBlockOnFirstStr b = (Nothing, b)

-- | @getCodeBlockLang attributes@ returns the language string if it is the only
-- class in the code block's attributes.
getCodeBlockLang :: Attr -> Maybe T.Text
getCodeBlockLang (_, [cls], _) = Just cls
getCodeBlockLang (_, _    , _) = Nothing

-- | @isMacroFormat text@ returns True if the given text is surrounded by curly
-- braces.
isMacroFormat :: T.Text -> Bool
isMacroFormat txt = startsWith "{" txt && endsWith "}" txt
  where
    startsWith ch = (== ch) . T.take 1
    endsWith ch = (== ch) . T.takeEnd 1

-- | @parseMacro text@ attempts to parse some inline string as a Confluence
-- macro, throwing a runtime exception if unable to parse!
--
-- WARNING: this is a partial function!
--
parseMacro :: T.Text -> (MacroName, [MacroOption])
parseMacro = second parseMacroOpts . splitTup ':' . macroContents
  where
    macroContents = T.dropAround (\c -> c == '{' || c == '}')
    parseMacroOpts =
        map (splitTup '=') . filter (not . T.null) . T.split (== '|')
    splitTup ch = second (T.drop 1) . T.break (== ch)

--------------------------------------------------------------------------------
