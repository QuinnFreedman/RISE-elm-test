module ModelUpdate exposing
    ( redo
    , undo
    , updateBookAndPushUndo
    )

import Messages exposing (BookUpdate(..))
import Model exposing (Book, Model, Page, Widget, WidgetType(..))
import SelectList exposing (Position(..))
import Util exposing (updateSelected)
import WidgetUtils exposing (initWidget)


updateBook : BookUpdate -> Book -> Book
updateBook msg book =
    case msg of
        UpdateWidgets widgets ->
            widgets |> List.foldl putWidget book

        UpdateWidget widget ->
            putWidget widget book

        InsertWidgetFromFile path ->
            insertWidgetFromFile path book


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


getNewId : Book -> ( String, Book )
getNewId book =
    let
        id =
            String.fromInt book.widgetIdCounter

        newBook =
            { book | widgetIdCounter = book.widgetIdCounter + 1 }
    in
    ( id, newBook )


insertWidgetFromFile : String -> Book -> Book
insertWidgetFromFile path book =
    let
        ( id, newBook ) =
            getNewId book

        newWidget =
            initWidget ("image-" ++ id) (ImageWidget path) 400 300 200 200
    in
    updateSelectedPage
        (\page ->
            { page
                | widgets = page.widgets ++ [ newWidget ]
            }
        )
        newBook


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
