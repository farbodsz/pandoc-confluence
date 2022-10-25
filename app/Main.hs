--------------------------------------------------------------------------------

module Main
    ( main
    ) where

import           Confluence.Writer
import           Text.Pandoc.JSON               ( ToJSONFilter(toJSONFilter) )

--------------------------------------------------------------------------------

main :: IO ()
main = do
    toJSONFilter inlineFilter

--------------------------------------------------------------------------------
