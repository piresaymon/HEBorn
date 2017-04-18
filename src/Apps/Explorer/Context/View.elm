module Apps.Explorer.Context.View
    exposing
        ( contextView
        , contextNav
        , contextContent
        )

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)
import OS.WindowManager.ContextHandler.View
    exposing
        ( contextForCreator
        , contextViewCreator
        )
import Apps.Instances.Models exposing (InstanceID)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages as ExplorerMsg
import Apps.Explorer.Context.Messages exposing (Msg(..), MenuAction(..))
import Apps.Explorer.Context.Models exposing (Context(..))


contextView : Model -> InstanceID -> Html ExplorerMsg.Msg
contextView model id =
    contextViewCreator
        ExplorerMsg.ContextMsg
        model
        model.context
        MenuMsg
        (menu id)


contextFor : Context -> Html.Attribute ExplorerMsg.Msg
contextFor context =
    contextForCreator ExplorerMsg.ContextMsg MenuMsg context


menu : InstanceID -> Model -> Context -> List (List ( ContextMenu.Item, Msg ))
menu id model context =
    case context of
        ContextNav ->
            [ [ ( ContextMenu.item "A", MenuClick DoA id )
              , ( ContextMenu.item "B", MenuClick DoB id )
              ]
            ]

        ContextContent ->
            [ [ ( ContextMenu.item "c", MenuClick DoB id )
              , ( ContextMenu.item "d", MenuClick DoA id )
              ]
            ]


contextNav : Html.Attribute ExplorerMsg.Msg
contextNav =
    contextFor ContextNav


contextContent : Html.Attribute ExplorerMsg.Msg
contextContent =
    contextFor ContextContent