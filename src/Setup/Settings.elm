module Setup.Settings
    exposing
        ( Settings(..)
        , SettingTopic(..)
        , groupSettings
        , encodeSettings
        , decodeErrors
        )

import Dict as Dict
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Utils.Ports.Leaflet exposing (Coordinates)


type Settings
    = Location Coordinates
    | Name String


type SettingTopic
    = AccountTopic
    | ServerTopic


groupSettings : List Settings -> List ( SettingTopic, List Settings )
groupSettings settings =
    let
        reducer setting dict =
            let
                target =
                    getTarget setting

                settings =
                    dict
                        |> Dict.get (toString target)
                        |> Maybe.withDefault []
                        |> (::) setting

                dict_ =
                    Dict.insert (toString target) settings dict
            in
                dict_

        filterer k v =
            case targetFromString k of
                Just target ->
                    Just ( target, v )

                Nothing ->
                    Nothing
    in
        settings
            |> List.foldl reducer Dict.empty
            |> Dict.toList
            |> List.filterMap (uncurry filterer)


encodeSettings : Settings -> ( String, Value )
encodeSettings setting =
    let
        key =
            settingToString setting

        value =
            case setting of
                Location coord ->
                    encodeLocation coord

                Name name ->
                    encodeHostname name
    in
        ( key, value )


decodeErrors : List Settings -> Decoder (List Settings)
decodeErrors =
    let
        filter checking errs =
            List.filter (settingToString >> flip List.member errs) checking

        decoder checking =
            Decode.string
                |> Decode.list
                |> Decode.field "fields"
                |> Decode.map (filter checking)
    in
        decoder



-- internals


settingToString : Settings -> String
settingToString setting =
    case setting of
        Location _ ->
            "location"

        Name _ ->
            "hostname"


encodeLocation : Coordinates -> Value
encodeLocation { lat, lng } =
    Encode.object
        [ ( "lat", Encode.float lat )
        , ( "lng", Encode.float lng )
        ]


encodeHostname : String -> Value
encodeHostname name =
    Encode.object
        [ ( "hostname", Encode.string name ) ]


getTarget : Settings -> SettingTopic
getTarget settings =
    case settings of
        Location _ ->
            ServerTopic

        Name _ ->
            ServerTopic


targetFromString : String -> Maybe SettingTopic
targetFromString str =
    case str of
        "AccountTopic" ->
            Just AccountTopic

        "ServerTopic" ->
            Just ServerTopic

        _ ->
            Nothing
