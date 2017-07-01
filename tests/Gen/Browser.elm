module Gen.Browser exposing (..)

import Fuzz exposing (Fuzzer)
import Gen.Utils exposing (fuzzer, unique, stringRange, listRange)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , int
        , list
        , choices
        , map
        , map3
        , andThen
        )
import Apps.Browser.Models exposing (..)
import Apps.Browser.Pages.Models as Pages
import Game.Web.Types as Web


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


page : Fuzzer Pages.Model
page =
    fuzzer genPage


emptyPage : Fuzzer Pages.Model
emptyPage =
    fuzzer genEmptyPage


pageList : Fuzzer (List Pages.Model)
pageList =
    fuzzer genPageList


emptyHistory : Fuzzer BrowserHistory
emptyHistory =
    fuzzer genEmptyHistory


nonEmptyHistory : Fuzzer BrowserHistory
nonEmptyHistory =
    fuzzer genNonEmptyHistory


history : Fuzzer BrowserHistory
history =
    fuzzer genHistory


emptyBrowser : Fuzzer Browser
emptyBrowser =
    fuzzer genEmptyBrowser


nonEmptyBrowser : Fuzzer Browser
nonEmptyBrowser =
    fuzzer genNonEmptyBrowser


browser : Fuzzer Browser
browser =
    fuzzer genBrowser


model : Fuzzer Browser
model =
    fuzzer genModel


emptyModel : Fuzzer Browser
emptyModel =
    fuzzer genEmptyModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genPage : Generator Pages.Model
genPage =
    -- TODO: generate other site tpes
    let
        generate str =
            let
                site =
                    { type_ = Web.Default
                    , url = str
                    , meta =
                        str
                            |> Web.DefaultMetadata
                            |> Web.DefaultMeta
                            |> Just
                    }
            in
                Pages.initialModel site
    in
        map generate unique


genEmptyPage : Generator Pages.Model
genEmptyPage =
    constant <|
        Pages.initialModel
            { type_ = Web.Blank
            , url = "about:blank"
            , meta = Nothing
            }


genPageList : Generator (List Pages.Model)
genPageList =
    andThen ((flip list) genPage) (int 2 10)


genEmptyHistory : Generator BrowserHistory
genEmptyHistory =
    constant []


genNonEmptyHistory : Generator BrowserHistory
genNonEmptyHistory =
    genPageList


genHistory : Generator BrowserHistory
genHistory =
    choices [ genEmptyHistory, genNonEmptyHistory ]


genEmptyBrowser : Generator Browser
genEmptyBrowser =
    constant initialBrowser


genNonEmptyBrowser : Generator Browser
genNonEmptyBrowser =
    let
        mapper =
            \past future current ->
                Browser
                    (Pages.getTitle current)
                    current
                    past
                    future
    in
        map3 mapper
            genNonEmptyHistory
            genNonEmptyHistory
            genPage


genBrowser : Generator Browser
genBrowser =
    choices [ genEmptyBrowser, genNonEmptyBrowser ]


genModel : Generator Browser
genModel =
    genNonEmptyBrowser


genEmptyModel : Generator Browser
genEmptyModel =
    genEmptyBrowser
