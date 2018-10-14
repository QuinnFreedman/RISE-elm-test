module Model exposing (Book, Model, MyDragState(..), Page, Position, Widget, init)

import Draggable
import SelectList exposing (SelectList)


type alias Model =
    { book : Book
    , drag : Draggable.State ()
    , myDragState : Maybe MyDragState
    , undoStack : List Book
    , redoStack : List Book
    }


type alias Book =
    { pages : SelectList Page
    }


type alias Page =
    { widgets : List Widget
    }


type alias Widget =
    { id : String
    , x : Float
    , y : Float
    , width : Float
    , height : Float
    }


type MyDragState
    = MovingWidget { id : String, dx : Float, dy : Float }
    | ResizingWidgetUp { id : String, delta : Float }
    | ResizingWidgetDown { id : String, delta : Float }
    | ResizingWidgetRight { id : String, delta : Float }
    | ResizingWidgetLeft { id : String, delta : Float }
    | DraggingSelection { initialX : Float, initialY : Float, dx : Float, dy : Float }


type alias Position =
    { x : Float
    , y : Float
    }


init : Model
init =
    { book =
        { pages =
            SelectList.singleton
                { widgets =
                    [ { id = "test"
                      , x = 100
                      , y = 200
                      , width = 80
                      , height = 80
                      }
                    ]
                }
        }
    , drag = Draggable.init
    , myDragState = Nothing
    , undoStack = []
    , redoStack = []
    }
