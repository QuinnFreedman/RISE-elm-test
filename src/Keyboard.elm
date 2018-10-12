module Keyboard exposing (KeyEvent, subscribeKeyPressed)

import Browser.Events as Events
import Json.Decode as Decode exposing (Decoder, bool, string)
import Json.Decode.Pipeline exposing (required)


type alias KeyEvent =
    { key : String
    , ctrlKey : Bool
    , shiftKey : Bool
    , altKey : Bool
    }


keyDecoder : Decoder KeyEvent
keyDecoder =
    Decode.succeed KeyEvent
        |> required "key" string
        |> required "ctrlKey" bool
        |> required "shiftKey" bool
        |> required "altKey" bool


subscribeKeyPressed : (KeyEvent -> msg) -> Sub msg
subscribeKeyPressed msg =
    Events.onKeyPress
        (Decode.map msg keyDecoder)
