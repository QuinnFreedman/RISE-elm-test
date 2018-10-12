module Main exposing (init, main, update, view)

import Browser
import Css exposing (..)
import DragHelpers exposing (dragStopped, dragged, handleDrag)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder)
import Keyboard exposing (subscribeKeyPressed)
import Messages exposing (Msg(..))
import Model exposing (..)
import ModelUpdate exposing (redo, undo, updateBookAndPushUndo)
import SelectList
import Util exposing (styleSheet)
import Widget exposing (renderDraggableWidget)


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


dragConfig : Draggable.Config MyDragState Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart OnDragStart
        , onDragEnd OnDragEnd
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnDragBy delta ->
            ( { model | myDragState = dragged model.myDragState delta }
            , Cmd.none
            )

        OnDragStart dragState ->
            ( { model | myDragState = Just dragState }, Cmd.none )

        OnDragEnd ->
            dragStopped msg model

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        UpdateBook bookUpdate ->
            ( updateBookAndPushUndo bookUpdate model, Cmd.none )

        KeyPressed { key, ctrlKey, shiftKey } ->
            case ( ctrlKey, shiftKey, key ) of
                ( True, False, "z" ) ->
                    ( undo model, Cmd.none )

                ( True, False, "y" ) ->
                    ( redo model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            -- ( model, Cmd.none )
            Debug.todo ""


view : Model -> Html Msg
view model =
    div
        [ css
            [ backgroundColor (rgb 255 255 255)
            , width (pct 100)
            , height (pct 100)
            , position absolute
            ]

        -- , handleDrag (DraggingSelection {initialX = 0, initialY = 0, dx = 0, dy = 0 })
        ]
        ([ styleSheet "/reset.css"
         , div
            [ css
                [ position absolute
                , fontFamily monospace
                ]
            ]
            [ text (Debug.toString model)
            ]
         ]
            ++ ((SelectList.selected model.book.pages).widgets
                    |> List.map
                        (\w -> renderDraggableWidget w model.myDragState)
               )
        )


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Sub.batch
        [ Draggable.subscriptions DragMsg drag
        , subscribeKeyPressed KeyPressed
        ]
