module Reach.EmbeddedFiles where

import Data.ByteString (ByteString)
import Data.FileEmbed

runtime_smt2 :: ByteString
runtime_smt2 = $(embedFile "./smt2/runtime.smt2")

runtime_bt_smt2 :: ByteString
runtime_bt_smt2 = $(embedFile "./smt2/runtime-bt.smt2")

stdlib_sol :: ByteString
stdlib_sol = $(embedFile "./sol/stdlib.sol")

stdlib_rsh :: ByteString
stdlib_rsh = $(embedFile "./rsh/stdlib.rsh")

stdlib_exp_rsh :: ByteString
stdlib_exp_rsh = $(embedFile "./rsh/stdlib.exp.rsh")