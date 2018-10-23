module Messages exposing (BookUpdate(..), Msg(..))

import Drag exposing (MouseEvent)
import Keyboard exposing (KeyEvent)
import Model exposing (..)


type Msg
    = OnDragBy Drag.Position
    | OnDragStart MyDragState
    | OnDragEnd
    | OnClickDraggable MyDragState MouseEvent
    | DragMsg (Drag.DragMsg MyDragState)
    | UpdateBook BookUpdate
    | KeyPressed KeyEvent
    | MenuTabSelected MenuBarTab
    | Undo
    | Redo
    | NoOp


type BookUpdate
    = UpdateWidgets (List Widget)
    | UpdateWidget Widget
    | InsertWidgetFromFile String
