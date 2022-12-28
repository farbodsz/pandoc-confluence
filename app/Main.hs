--------------------------------------------------------------------------------

module Main (
    main,
) where

import Confluence.Writer
import Text.Pandoc.Definition (Pandoc)
import Text.Pandoc.Generic (bottomUp)
import Text.Pandoc.JSON (ToJSONFilter (toJSONFilter))

--------------------------------------------------------------------------------

main :: IO ()
main = toJSONFilter pandocFilter

pandocFilter :: Pandoc -> Pandoc
pandocFilter =
    bottomUp (concatMap blockFilter) . bottomUp (concatMap inlineFilter)

--------------------------------------------------------------------------------
