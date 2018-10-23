module Main exposing (main)

import Browser
import Drag
import Html.Styled exposing (toUnstyled)
import Keyboard exposing (subscribeKeyPressed)
import Messages exposing (BookUpdate(..), Msg(..))
import Model exposing (..)
import Port exposing (fileDropped)
import Update exposing (update)
import Util exposing (styleSheet)
import View exposing (view)


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd msg )
init flags =
    ( Model.init
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Sub.batch
        [ Drag.subscriptions drag DragMsg
        , subscribeKeyPressed KeyPressed
        , fileDropped (UpdateBook << InsertWidgetFromFile)
        ]
