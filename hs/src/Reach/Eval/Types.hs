{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Reach.Eval.Types where

import qualified Data.Map.Strict as M
import Generics.Deriving
import Reach.AST.Base
import Reach.AST.DLBase
import Reach.AST.SL
import Reach.AST.DL (DLBlock)

recursionDepthLimit :: Int
recursionDepthLimit = 2 ^ (16 :: Int)

type SLValTy = (SLVal, Maybe DLType)

data SLMode
  = --- The top-level of a module, before the App starts
    SLM_Module
  | --- The app starts in a "step"
    SLM_Step
  | --- An "only" moves from "step" to "local step" and then to "step" again, where x = live
    SLM_LocalStep
  | SLM_LocalPure
  | --- A "toconsensus" moves from "step" to "consensus step" then to "step" again
    SLM_ConsensusStep
  | SLM_ConsensusPure
  deriving (Bounded, Enum, Eq, Generic)

instance Show SLMode where
  show = \case
    SLM_Module -> "module"
    SLM_Step -> "step"
    SLM_LocalStep -> "local step"
    SLM_LocalPure -> "local pure"
    SLM_ConsensusStep -> "consensus step"
    SLM_ConsensusPure -> "consensus pure"

--- A state represents the state of the protocol, so it is returned
--- out of a function call.
data SLState = SLState
  { --- A function call may modify the mode
    st_mode :: SLMode
  , st_live :: Bool
  , st_after_first :: Bool
  , --- A function call may cause a participant to join
    st_pdvs :: SLPartDVars
  }
  deriving (Eq, Show)

all_slm_modes :: [SLMode]
all_slm_modes = enumFrom minBound

pure_mode :: SLMode -> SLMode
pure_mode (SLM_LocalStep) = SLM_LocalPure
pure_mode (SLM_ConsensusStep) = SLM_ConsensusPure
pure_mode ow = ow

type SLPartDVars = M.Map SLPart DLVar

data DLValue
  = DLV_Arg SrcLoc DLArg
  | DLV_Fun SrcLoc [DLVar] DLBlock
  | DLV_Array SrcLoc DLType [DLValue]
  | DLV_Tuple SrcLoc [DLValue]
  | DLV_Obj SrcLoc (M.Map SLVar DLValue)
  | DLV_Data SrcLoc (M.Map SLVar DLType) String DLValue
  | DLV_Struct SrcLoc [(SLVar, DLValue)]

instance SrcLocOf DLValue where
  srclocOf = \case
    DLV_Arg at _ -> at
    DLV_Fun at _ _ -> at
    DLV_Array at _ _ -> at
    DLV_Tuple at _ -> at
    DLV_Obj at _ -> at
    DLV_Data at _ _ _ -> at
    DLV_Struct at _ -> at
