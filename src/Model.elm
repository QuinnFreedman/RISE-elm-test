module Model exposing
    ( Book
    , BookUpdate(..)
    , Model
    , Msg(..)
    , MyDragState(..)
    , Page
    , Position
    , Rect
    , Widget
    , getSelectedPage
    , init
    )

import Drag exposing (MouseEvent)
import Keyboard exposing (KeyEvent)
import SelectList exposing (SelectList)
import Set exposing (Set)


type alias Model =
    { book : Book
    , drag : Drag.DragState MyDragState
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
                    , { id = "test2"
                      , x = 400
                      , y = 300
                      , width = 100
                      , height = 70
                      }
                    ]
                }
        }
    , drag = Drag.init
    , myDragState = Nothing
    , undoStack = []
    , redoStack = []
    , selectedWidgets = Set.empty
    }


type Msg
    = OnDragBy Drag.Position
    | OnDragStart MyDragState
    | OnDragEnd
    | OnClickDraggable MyDragState MouseEvent
    | DragMsg (Drag.DragMsg MyDragState)
    | UpdateBook BookUpdate
    | KeyPressed KeyEvent
    | NoOp


type BookUpdate
    = UpdateWidgets (List Widget)


getSelectedPage : Model -> Page
getSelectedPage model =
    SelectList.selected model.book.pages
