module ModelUpdate exposing (redo, undo, updateBookAndPushUndo)

import Messages exposing (BookUpdate(..))
import Model exposing (Book, Model, Page, Widget)
import SelectList exposing (Position(..))
import Util exposing (updateSelected)


updateBook : BookUpdate -> Book -> Book
updateBook msg book =
    case msg of
        UpdateWidgets widgets ->
            widgets |> List.foldl putWidget book


updateBookAndPushUndo : BookUpdate -> Model -> Model
updateBookAndPushUndo msg model =
    { model
        | undoStack = model.book :: model.undoStack
        , redoStack = []
        , book = updateBook msg model.book
    }


undo : Model -> Model
undo model =
    case model.undoStack of
        head :: tail ->
            { model
                | book = head
                , undoStack = tail
                , redoStack = model.book :: model.redoStack
            }

        [] ->
            model


redo : Model -> Model
redo model =
    case model.redoStack of
        head :: tail ->
            { model
                | book = head
                , redoStack = tail
                , undoStack = model.book :: model.undoStack
            }

        [] ->
            model


putWidget : Widget -> Book -> Book
putWidget widget book =
    updateSelectedPage
        (\page ->
            { page
                | widgets =
                    List.map
                        (\w ->
                            if w.id == widget.id then
                                widget

                            else
                                w
                        )
                        page.widgets
            }
        )
        book


updateSelectedPage : (Page -> Page) -> Book -> Book
updateSelectedPage f book =
    { book
        | pages = book.pages |> updateSelected f
    }
