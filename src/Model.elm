module Model exposing
    ( AspectRatio
    , Book
    , MenuBarTab(..)
    , Model
    , MyDragState(..)
    , Page
    , Position
    , Rect
    , Widget
    , WidgetType(..)
    , getSelectedPage
    , init
    )

import Css exposing (Color, rgb)
import Drag exposing (MouseEvent)
import SelectList exposing (SelectList)
import Set exposing (Set)


type alias Model =
    { book : Book
    , drag : Drag.DragState MyDragState
    , myDragState : Maybe MyDragState
    , undoStack : List Book
    , redoStack : List Book
    , selectedWidgets : Set String
    , menuBarTabs : SelectList MenuBarTab
    , clipboard : List Widget
    , zoom : Int
    }


type alias Book =
    { pages : SelectList Page
    , aspectRatio : AspectRatio
    , widgetIdCounter : Int
    }


type alias Page =
    { id : String
    , widgets : List Widget
    }


type alias Widget =
    { id : String
    , x : Float
    , y : Float
    , width : Float
    , height : Float
    , backgroundColor : Color
    , borderColor : Color
    , borderWidth : Float
    , borderRadius : Float
    , padding : Float
    , widgetType : WidgetType
    , zIndex : Int
    }


type WidgetType
    = TextShapeWidget String
    | ImageWidget String
    | VideoWidget String


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


type alias AspectRatio =
    { width : Float
    , height : Float
    }


type MenuBarTab
    = File
    | Edit
    | Insert


initMenuBarTabs =
    SelectList.fromLists [ File ] Edit [ Insert ]


init : Model
init =
    { book =
        { pages =
            SelectList.singleton
                { id = "-1"
                , widgets =
                    [ { id = "test"
                      , x = 100
                      , y = 200
                      , width = 80
                      , height = 80
                      , backgroundColor = rgb 255 100 200
                      , borderColor = rgb 0 0 0
                      , borderWidth = 2
                      , borderRadius = 10
                      , padding = 10
                      , widgetType = TextShapeWidget "test"
                      , zIndex = 1
                      }
                    , { id = "test2"
                      , x = 400
                      , y = 300
                      , width = 260
                      , height = 170
                      , backgroundColor = rgb 255 100 0
                      , borderColor = rgb 0 0 0
                      , borderWidth = 0
                      , borderRadius = 0
                      , padding = 10
                      , widgetType = TextShapeWidget "## Markdown\n\n* It will be easy to add a **full** _rich text_ editor in `html` but for now I'm using markdown"
                      , zIndex = 1
                      }
                    ]
                }
        , aspectRatio =
            { width = 1280
            , height = 720
            }
        , widgetIdCounter = 0
        }
    , drag = Drag.init
    , myDragState = Nothing
    , undoStack = []
    , redoStack = []
    , selectedWidgets = Set.empty
    , menuBarTabs = initMenuBarTabs
    , clipboard = []
    , zoom = 100
    }


getSelectedPage : Model -> Page
getSelectedPage model =
    SelectList.selected model.book.pages
