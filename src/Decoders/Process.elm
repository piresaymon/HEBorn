module Decoders.Process exposing (..)

import Dict exposing (Dict)
import Game.Network.Types exposing (NIP)
import Game.Servers.Processes.Models exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Utils.Json.Decode exposing (optionalMaybe)


processDict : Decoder (Dict ID Process)
processDict =
    map Dict.fromList processList


processList : Decoder (List ( ID, Process ))
processList =
    list process


process : Decoder ( ID, Process )
process =
    decode Process
        |> required "type" type_
        |> required "access" access
        |> required "state" state
        |> optionalMaybe "file" file
        |> optionalMaybe "progress" progress
        |> custom network
        |> andThen insertId


network : Decoder NIP
network =
    decode (,)
        |> required "network_id" string
        |> required "target_ip" string


insertId : Process -> Decoder ( ID, Process )
insertId process =
    decode (flip (,) process)
        |> required "process_id" string


type_ : Decoder Type
type_ =
    let
        decodeEncryptor =
            decode EncryptorContent
                |> required "target_log_id" string

        decodeData value =
            field "data" value

        decodeType value =
            case value of
                "Cracker" ->
                    succeed Cracker

                "Decryptor" ->
                    succeed Decryptor

                "Encryptor" ->
                    map Encryptor <| decodeData decodeEncryptor

                "File Transference" ->
                    succeed FileTransference

                "Passive Firewall" ->
                    succeed PassiveFirewall

                value ->
                    fail ("Unknown process type `" ++ value ++ "'")
    in
        andThen decodeType string


access : Decoder Access
access =
    let
        full =
            decode FullAccess
                |> required "origin_id" string
                |> required "priority" priority
                |> required "usage" resourcesUsage
                |> optional "connection_id" (maybe string) Nothing
                |> map Full

        partial =
            decode PartialAccess
                |> optional "connection_id" (maybe string) Nothing
                |> map Partial
    in
        oneOf [ full, partial ]


state : Decoder State
state =
    let
        decode value =
            case value of
                "running" ->
                    succeed Running

                "paused" ->
                    succeed Paused

                "succeeded" ->
                    succeed Succeeded

                "failed" ->
                    succeed <| Failed Unknown

                value ->
                    fail ("Invalid process state `" ++ value ++ "'")
    in
        andThen decode string


priority : Decoder Priority
priority =
    let
        decode num =
            case num of
                1 ->
                    succeed Lowest

                2 ->
                    succeed Low

                3 ->
                    succeed Normal

                4 ->
                    succeed High

                5 ->
                    succeed Highest

                n ->
                    fail ("Unknown priority `" ++ (toString n) ++ "'")
    in
        andThen decode int


resourcesUsage : Decoder ResourcesUsage
resourcesUsage =
    decode ResourcesUsage
        |> required "cpu" usage
        |> required "mem" usage
        |> required "down" usage
        |> required "up" usage


usage : Decoder Usage
usage =
    decode (,)
        |> required "percentage" float
        |> required "absolute" int


progress : Decoder Progress
progress =
    decode Progress
        |> required "creation_date" float
        |> optionalMaybe "percentage" float
        |> optionalMaybe "completion_date" float


file : Decoder ProcessFile
file =
    decode ProcessFile
        |> optionalMaybe "id" string
        |> optionalMaybe "version" float
        |> required "name" string
