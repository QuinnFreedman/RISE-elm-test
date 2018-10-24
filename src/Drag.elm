module Drag exposing
    ( DragConfig
    , DragMsg
    , DragState
    , MouseEvent
    , Position
    , handleDrag
    , init
    , subscriptions
    , update
    )

import Browser.Events
import Html exposing (Attribute)
import Html.Events
import Json.Decode as Decode exposing (Decoder, bool, float, int)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Task


type alias DragConfig a userMsg =
    { onDragStart : a -> userMsg
    , onDragged : Position -> userMsg
    , onDragStopped : userMsg
    , onClick : a -> MouseEvent -> userMsg
    }


type DragState a
    = NotDragging
    | AboutToDrag a MouseEvent
    | Dragging a Position Position


type DragMsg a
    = MouseDown a MouseEvent
    | MouseDragged MouseMove
    | MouseUp


type MouseButton
    = LeftButton
    | MiddleButton
    | RightButton
    | OtherButton Int


type alias MouseEvent =
    { offsetX : Float
    , offsetY : Float
    , pageX : Float
    , pageY : Float
    , screenX : Float
    , screenY : Float
    , button : MouseButton
    , altPressed : Bool
    , ctrlPressed : Bool
    , shiftPressed : Bool
    , meatPressed : Bool
    }


type alias Position =
    { x : Float
    , y : Float
    }


type alias MouseMove =
    { x : Float
    , y : Float
    , dx : Float
    , dy : Float
    }


init : DragState a
init =
    NotDragging


type alias Envelope dragState userMsg =
    DragMsg dragState -> userMsg


handleDrag : (MouseEvent -> a) -> Envelope a msg -> Attribute msg
handleDrag initState envelope =
    Html.Events.custom
        "mousedown"
        (Decode.map
            (alwaysPreventDefaultAndStopPropagation
                << envelope
                << (\e -> MouseDown (initState e) e)
            )
            mousePressedDecoder
        )


update : DragMsg a -> DragConfig a msg -> DragState a -> ( DragState a, Cmd msg )
update msg config model =
    case msg of
        MouseDown userState pos ->
            ( AboutToDrag userState pos, Cmd.none )

        MouseDragged move ->
            let
                newPos =
                    { x = move.x, y = move.y }
            in
            if move.dx == 0 && move.dy == 0 then
                ( model, Cmd.none )

            else
                case model of
                    AboutToDrag userState startEvent ->
                        ( Dragging userState (getPos startEvent) newPos
                        , thenFire <| config.onDragStart userState
                        )

                    Dragging userState startPos oldPos ->
                        ( Dragging userState startPos newPos
                        , thenFire <| config.onDragged (delta oldPos newPos)
                        )

                    NotDragging ->
                        Debug.todo "this shouldn't happen"

        MouseUp ->
            case model of
                AboutToDrag userState startEvent ->
                    ( NotDragging
                    , thenFire <| config.onClick userState startEvent
                    )

                _ ->
                    ( NotDragging, thenFire config.onDragStopped )


mouseMovedDecoder : Decoder MouseMove
mouseMovedDecoder =
    Decode.map4 MouseMove
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)
        (Decode.field "movementX" Decode.float)
        (Decode.field "movementY" Decode.float)


mousePressedDecoder : Decoder MouseEvent
mousePressedDecoder =
    Decode.succeed MouseEvent
        |> required "offsetX" float
        |> required "offsetY" float
        |> required "pageX" float
        |> required "pageY" float
        |> required "screenX" float
        |> required "screenY" float
        |> required "button" (Decode.map mouseButtonFromInt int)
        |> optional "altKey" bool False
        |> optional "ctrlKey" bool False
        |> optional "shiftKey" bool False
        |> optional "meatKey" bool False


getPos : { e | pageX : Float, pageY : Float } -> Position
getPos event =
    { x = event.pageX, y = event.pageY }


subscriptions : DragState a -> Envelope a msg -> Sub msg
subscriptions dragState envelope =
    case dragState of
        NotDragging ->
            Sub.none

        Dragging _ _ _ ->
            -- getSubscriptions dragState.config.envelope state oldPos
            getSubscriptions envelope

        AboutToDrag state oldPos ->
            getSubscriptions envelope


getSubscriptions : (DragMsg a -> msg) -> Sub msg
getSubscriptions envelope =
    [ Browser.Events.onMouseMove <|
        Decode.map MouseDragged mouseMovedDecoder
    , Browser.Events.onMouseUp <| Decode.succeed MouseUp
    ]
        |> Sub.batch
        |> Sub.map envelope


delta : Position -> Position -> Position
delta oldPos newPos =
    { x = newPos.x - oldPos.x
    , y = newPos.y - oldPos.y
    }


thenFire : msg -> Cmd msg
thenFire msg =
    Task.perform identity (Task.succeed msg)


mouseButtonFromInt code =
    case code of
        0 ->
            LeftButton

        1 ->
            MiddleButton

        2 ->
            RightButton

        n ->
            OtherButton n


alwaysPreventDefaultAndStopPropagation :
    msg
    ->
        { message : msg
        , stopPropagation : Bool
        , preventDefault : Bool
        }
alwaysPreventDefaultAndStopPropagation msg =
    { message = msg, stopPropagation = True, preventDefault = True }
