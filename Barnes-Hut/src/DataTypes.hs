{-# LANGUAGE DuplicateRecordFields #-}

module DataTypes where

import qualified Graphics.Gloss as G
import Data.LruCache

type Mass   = Float

data Pos = P { px :: !Float
             , py :: !Float
             } deriving (Show, Eq)

data Vel = V { vx :: !Float
             , vy :: !Float
             } deriving (Show, Eq)

data Acc = A { ax :: !Float
             , ay :: !Float
             } deriving (Show, Eq)

data Body = B { mass  :: !Mass
              , pos   :: !Pos
              , vel   :: !Vel
              , color :: !G.Color
              , trail :: [(Float, Float)]
              } deriving (Show, Eq)

data Universe = U { pixelToM     :: Float
                  , pixelToKg    :: !Float
                  , simTimeRatio :: !Float
                  , bodies       :: ![Body]
                  , barnesTree   :: !BarnesTree
                  , trails       :: !Bool
                  } deriving (Show, Eq)

data BarnesLeaf = Leaf { blCenter :: !Pos
                       , blWidth  :: !Float
                       }
                | Node { bnCMass  :: !Pos
                       , bnCenter :: !Pos
                       , bnWidth  :: !Float
                       , blMass   :: !Mass
                       , body     :: !Body
                       } deriving (Show, Eq)

data BarnesTree = Exter !BarnesLeaf
                | Inter { cMass    :: !Pos
                        , btCenter :: !Pos
                        , width    :: !Float
                        , btMass   :: !Mass
                        , nw       :: !BarnesTree
                        , ne       :: !BarnesTree
                        , sw       :: !BarnesTree
                        , se       :: !BarnesTree
                        } deriving (Eq)

data DebouncedLRU k v = DLRU { debounce :: Int
                             , count    :: Int
                             , lru      :: LruCache k v
                             } deriving (Show, Eq)

debouncedInsert :: Float -> (Float, Float) -> DebouncedLRU Float (Float, Float) -> DebouncedLRU Float (Float, Float)
debouncedInsert k v (DLRU d c cache)
  | c < d     = DLRU d (c + 1) cache
  | otherwise = DLRU d 0 (insert k v cache)

debouncedMt d s = DLRU d 0 (empty s)

forceInsert k v dlru = dlru { lru = insert k v (lru dlru) }

instance Show BarnesTree where
  show (Exter (Leaf (P x y) w)) = "Leaf: " ++ show x ++ " " ++ show y ++ " " ++ show w ++ "\n"
  show (Exter (Node (P x y) (P x' y') w m (B mb (P xb yb) _ _ _))) =
    "Exter Node: " ++ show x ++ " " ++ show y ++ " center: " ++ show x' ++ " " ++ show y' ++
    " " ++ show w ++ " " ++ show m ++ " " ++ "Body: " ++ show mb ++ " pos: " ++ show (xb, yb) ++ "\n"
  show (Inter (P cmx cmy) (P cm cy) w m q1 q2 q3 q4) =
    "Inter Node: ------>" ++ show (cmx, cmy) ++ " center: " ++ show (cm, cy) ++ " w: " ++ show w
    ++ " m: " ++ show m ++ "\n(Quadrants: ~~> \n" ++ show q1 ++ show q2 ++ show q3 ++ show q4 ++ ")\n"

