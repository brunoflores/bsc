module Main where

import CSyntax
import Depend
import Error
import FileIOUtil
import FlagsDecode
import Id
import Position

main :: IO ()
main = do
  let fname = "/home/bruno/devel/bsc/src/comp/examples/FibOne.bsv"
  errh <- initErrorHandle
  file <-
    readFileCatch
      errh
      noPosition
      fname
  pkg <-
    parseSrc
      False
      errh
      (defaultFlags "")
      True
      fname
      file
  print (show pkg)
