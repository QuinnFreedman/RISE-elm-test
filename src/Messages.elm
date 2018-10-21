module Messages exposing (BookUpdate(..), Msg(..))

import Model exposing (..)
import Drag exposing (MouseEvent)
import Keyboard exposing (KeyEvent)


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
