module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h2, input, p, text)
import Html.Attributes exposing (placeholder, style, value)
import Html.Events exposing (onClick, onInput)


type alias Model =
    List Task


type TaskStatus
    = Pending
    | Ongoing
    | Completed
    | Editing


type alias Task =
    { id : SelectedTaskId
    , name : String
    , description : String
    , status : TaskStatus
    }


type alias SelectedTaskId =
    Int


type Msg
    = UpdateTask Task
    | DeleteTask SelectedTaskId


init : ( Model, Cmd Msg )
init =
    ( defaultTasks
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


defaultTasks : List Task
defaultTasks =
    [ { id = 1
      , name = "Buy coffee"
      , description = "Buy coffee on monday"
      , status = Pending
      }
    , { id = 2
      , name = "Learn elm"
      , description = "Keep building this"
      , status = Pending
      }
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTask selectedTask ->
            let
                updatedTasks =
                    List.map
                        (\task ->
                            if task.id == selectedTask.id then
                                selectedTask

                            else
                                task
                        )
                        model
            in
            ( updatedTasks, Cmd.none )

        DeleteTask selectedTaskID ->
            ( List.filter (\task -> task.id /= selectedTaskID) model
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div []
        [ input [ placeholder "Enter new task" ] []
        , div [ style "display" "flex", style "flex-direction" "column", style "align-items" "flex-start" ]
            (List.map viewTaskCard model)
        ]


viewTaskCard : Task -> Html Msg
viewTaskCard task =
    let
        defaultWrapper children =
            div [ style "background-color" "lightgrey", style "margin-top" "1rem", style "width" "300px" ] children

        completedWrapper children =
            div [ style "background-color" "green", style "margin-top" "1rem", style "width" "300px" ] children

        editButton =
            button [ onClick <| UpdateTask { task | status = Editing } ] [ text "Edit" ]

        stopButton =
            button [ onClick <| UpdateTask { task | status = Pending } ] [ text "Stop" ]

        completeButton =
            button [ onClick <| UpdateTask { task | status = Completed } ] [ text "Complete" ]

        uncompleteButton =
            button [ onClick <| UpdateTask { task | status = Pending } ] [ text "Uncomplete" ]

        deleteButton =
            button [ onClick <| DeleteTask task.id ] [ text "Delete" ]
    in
    case task.status of
        Editing ->
            defaultWrapper
                [ stopButton
                , completeButton
                , deleteButton
                , div
                    [ style "padding" "1rem" ]
                    [ h2 [] [ viewTaskNameInput task ]
                    , p [] [ viewTaskDescriptionInput task ]
                    ]
                ]

        Completed ->
            completedWrapper
                [ uncompleteButton
                , deleteButton
                , div
                    [ style "padding" "1rem" ]
                    [ h2 [] [ text task.name ]
                    , p [] [ text task.description ]
                    ]
                ]

        _ ->
            defaultWrapper
                [ editButton
                , completeButton
                , deleteButton
                , div
                    [ style "padding" "1rem" ]
                    [ h2 [] [ text task.name ]
                    , p [] [ text task.description ]
                    ]
                ]


viewTaskNameInput : Task -> Html Msg
viewTaskNameInput task =
    input [ placeholder "Enter name", value task.name, onInput (\newValue -> UpdateTask { task | name = newValue }) ] []


viewTaskDescriptionInput : Task -> Html Msg
viewTaskDescriptionInput task =
    input [ placeholder "Enter description", value task.description, onInput (\newValue -> UpdateTask { task | description = newValue }) ] []
