{-# LANGUAGE RankNTypes, TypeOperators, FlexibleInstances, ScopedTypeVariables, GADTs, MultiParamTypeClasses, UndecidableInstances, IncoherentInstances #-}

--------------------------------------------------------------------------------
-- |
-- Module      :  Data.Comp.Multi.Foldable
-- Copyright   :  (c) 2011 Patrick Bahr
-- License     :  BSD3
-- Maintainer  :  Patrick Bahr <paba@diku.dk>
-- Stability   :  experimental
-- Portability :  non-portable (GHC Extensions)
--
-- This module defines higher-order foldable functors.
--
--------------------------------------------------------------------------------

module Data.Comp.Multi.Foldable
    (
     HFoldable (..),
     kfoldr,
     kfoldl,
     htoList
     ) where

import Data.Monoid
import Data.Maybe
import Data.Comp.Multi.Functor

-- | Higher-order functors that can be folded.
--
-- Minimal complete definition: 'hfoldMap' or 'hfoldr'.
class HFunctor h => HFoldable h where
    hfold :: Monoid m => h (K m) :=> m
    hfold = hfoldMap unK

    hfoldMap :: Monoid m => (a :=> m) -> h a :=> m
    hfoldMap f = hfoldr (mappend . f) mempty

    hfoldr :: (a :=> b -> b) -> b -> h a :=> b
    hfoldr f z t = appEndo (hfoldMap (Endo . f) t) z

    hfoldl :: (b -> a :=> b) -> b -> h a :=> b
    hfoldl f z t = appEndo (getDual (hfoldMap (Dual . Endo . flip f) t)) z


    hfoldr1 :: forall a. (a -> a -> a) -> h (K a) :=> a
    hfoldr1 f xs = fromMaybe (error "hfoldr1: empty structure")
                   (hfoldr mf Nothing xs)
          where mf :: K a :=> Maybe a -> Maybe a
                mf (K x) Nothing = Just x
                mf (K x) (Just y) = Just (f x y)

    hfoldl1 :: forall a . (a -> a -> a) -> h (K a) :=> a
    hfoldl1 f xs = fromMaybe (error "hfoldl1: empty structure")
                   (hfoldl mf Nothing xs)
          where mf :: Maybe a -> K a :=> Maybe a
                mf Nothing (K y) = Just y
                mf (Just x) (K y) = Just (f x y)

htoList :: (HFoldable f) => f a :=> [A a]
htoList = hfoldr (\ n l ->  A n : l) []
    
kfoldr :: (HFoldable f) => (a -> b -> b) -> b -> f (K a) :=> b
kfoldr f = hfoldr (\ (K x) y -> f x y)


kfoldl :: (HFoldable f) => (b -> a -> b) -> b -> f (K a) :=> b
kfoldl f = hfoldl (\ x (K y) -> f x y)