module Model exposing
    ( Book
    , Model
    , MyDragState(..)
    , Page
    , Position
    , Rect
    , Widget
    , init
    )

import Draggable
import SelectList exposing (SelectList)
import Set exposing (Set)


type alias Model =
    { book : Book
    , drag : Draggable.State ()
    , myDragState : Maybe MyDragState
    , undoStack : List Book
    , redoStack : List Book
    , selectedWidgets : Set String
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


type alias Rect =
    { x : Float
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
    | DraggingSelection Rect


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
    , selectedWidgets = Set.empty
    }
