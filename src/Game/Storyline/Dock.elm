module Game.Storyline.Dock exposing (dockApps)

import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp(..))
import Game.Storyline.Models exposing (Model, getCheckpoint)
import Game.Storyline.Shared exposing (..)


dockApps : Model -> List DesktopApp
dockApps model =
    [ Email ]
        |> addIf model Browser browserCheckpoint
        |> addIf model TaskManager taskManagerCheckpoint
        |> addIf model DBAdmin hackedDatabaseCheckpoint
        |> addIf model Explorer explorerCheckpoint



-- internals


addIf : Model -> DesktopApp -> Checkpoint -> List DesktopApp -> List DesktopApp
addIf model app checkpoint acu =
    if (checkpointIsGTE (getCheckpoint model) checkpoint) then
        app :: acu
    else
        acu


browserCheckpoint : Checkpoint
browserCheckpoint =
    checkpoint (Just Tutorial)
        (Just Tutorial_DownloadCracker)
        Nothing


taskManagerCheckpoint : Checkpoint
taskManagerCheckpoint =
    checkpoint (Just Tutorial)
        (Just Tutorial_NastyVirus)
        (Just DlaydMuch3)


hackedDatabaseCheckpoint : Checkpoint
hackedDatabaseCheckpoint =
    checkpoint (Just Tutorial)
        (Just Tutorial_NastyVirus)
        (Just DlaydMuch4)


explorerCheckpoint : Checkpoint
explorerCheckpoint =
    checkpoint (Just Tutorial)
        (Just Tutorial_NastyVirus)
        (Just NastyVirus3)
