module Decoders.Bootstrap exposing (..)

import Json.Decode as Decode exposing (Decoder, list, map)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Game.Storyline.Models as Story
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Models as Game
import Decoders.Servers
import Decoders.Storyline
import Decoders.Game


-- this is the outdated bootstrap


type alias Bootstrap =
    { story : Story.Model
    , serverIndex : ServerIndex
    }


type alias ServerIndex =
    { player : List ( Servers.ID, Servers.Server )
    , remotes : List ( Servers.ID, Servers.Server )
    }


type alias GenericServers =
    List ( Servers.ID, Servers.Server )


toModel : Game.Model -> Bootstrap -> Game.Model
toModel game got =
    let
        servers =
            got.serverIndex
                |> joinIndexes
                |> List.foldl (uncurry Servers.insert) game.servers
    in
        Game.Model
            game.account
            servers
            game.meta
            got.story
            game.web
            game.config


joinIndexes : ServerIndex -> GenericServers
joinIndexes { player, remotes } =
    player ++ remotes


bootstrap : Decoder Bootstrap
bootstrap =
    decode Bootstrap
        |> optional "story" Decoders.Storyline.story Story.initialModel
        |> required "servers" serverIndex


serverIndex : Decoder ServerIndex
serverIndex =
    decode ServerIndex
        |> required "player" (list Decoders.Servers.serverWithId)
        |> required "remotes" (list Decoders.Servers.serverWithId)
