module Game.Servers.Logs.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Logs.Models exposing (..)


update :
    Msg
    -> Logs
    -> GameModel
    -> ( Logs, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        UpdateContent logId value ->
            let
                model_ =
                    updateContent model logId value
            in
                ( model_, Cmd.none, [] )

        Crypt logId ->
            let
                model_ =
                    crypt model logId
            in
                ( model_, Cmd.none, [] )

        Uncrypt logId restauredContent ->
            ( model, Cmd.none, [] )
