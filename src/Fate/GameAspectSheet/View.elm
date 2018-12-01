module Fate.GameAspectSheet.View
    exposing
    ( editView
    , view
    )

import Array exposing (Array)
import Fate.GameAspectSheet.Types exposing (..)
import Fate.CharacterSheet.Types exposing (Aspect(..))
import Fate.CharacterSheet.View
    exposing
    ( inputStyles
    , sectionLabel
    , defaultButton
    , userSelect_none
    )
import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as HA exposing (..)
import Html.Styled.Events exposing (..)


view : Model -> Html Msg
view model =
    div
        [ css
            [ padding3 (px 0) (Css.em 1) (Css.em 1)
            , overflowWrap breakWord
            ]
        ]
    (Array.toList (Array.indexedMap sceneView model.scenes))


sceneView : Index -> Scene -> Html Msg
sceneView index { title, aspects } =
  div
      []
      [ titleView title
      , aspectView index aspects
      ]

titleView : String -> Html Msg
titleView title =
    div [ css
          [ fontWeight bold
          , fontSize (Css.em 1.2)
          , backgroundColor (hex "fff")
          , borderBottom3 (px 1) solid (hex "ccc")
          , marginBottom (Css.em 0.25)
          , padding3 (Css.em 0.5) (px 0) (Css.em 0.25)
          ]
        ]
    [ text title ]

aspectView : Index -> Array Aspect -> Html Msg
aspectView sceneIndex aspects =
    let
        aspectView_ index (Aspect title invokes) =
            div
                [ css
                    [ displayFlex
                    , alignItems center
                    , justifyContent spaceBetween
                    ]
                , class "reveal-buttons-on-hover"
                ]
                [ span [] [ text title ]
                , invokesView sceneIndex index (Aspect title invokes)
                ]
    in
    if Array.isEmpty aspects then
        text ""

    else
        div
            [ css
                [ marginTop (Css.em 1) ]
            ]
            [ text "" --sectionLabel "Aspects"
            , div [] <|
                Array.toList <|
                    Array.indexedMap
                        aspectView_
                        aspects
            ]

invokesView : Index -> Index -> Aspect -> Html Msg
invokesView sceneIndex aspectIndex (Aspect title invokes) =
    let
        invokeButton =
            styled defaultButton
                [ opacity (int 0)
                , hover
                    [ opacity (int 1) ]
                ]

        addInvokeButton =
            invokeButton
                [ onClick
                    (UpdateAspect
                         sceneIndex
                         aspectIndex
                         (Aspect title (invokes + 1))
                    )
                ]
                [ text "+" ]

        removeInvokeButton =
            invokeButton
                [ onClick
                    (UpdateAspect
                         sceneIndex
                         aspectIndex
                         (Aspect title (invokes - 1))
                    )
                ]
                [ text "-" ]

        content =
            if invokes > 0 then
                [ removeInvokeButton
                , span
                    [ css
                        [ backgroundColor (hex "663399")
                        , color (hex "fff")
                        , borderRadius (px 999)
                        , padding2 (Css.em 0.25) (Css.em 0.6)
                        , fontSize (Css.em 0.75)
                        ]
                    ]
                    [ text (String.fromInt invokes) ]
                , addInvokeButton
                ]

            else
                [ addInvokeButton ]
    in
    span
        [ css
            [ whiteSpace noWrap
            , userSelect_none
            ]
        ]
        content



editView : Model -> Html Msg
editView model =
    div
        [ css
            [ maxWidth (Css.em 32)
            ]
        ]
    [ editScenesView model.scenes ]

editScenesView : Array Scene -> Html Msg
editScenesView scenes =
    div
        [ css
            [ marginTop (Css.em 1) ]
        ]
        [ div [] <|
            Array.toList <|
                Array.indexedMap
                    editSceneView
                    scenes
        , defaultButton
            [ onClick AddNewScene ]
            [ text "Add New Scene" ]
        ]

editSceneView : Index -> Scene -> Html Msg
editSceneView index { title, aspects } =
    div
        [ css
            [ marginTop (Css.em 1) ]
        ]
    [ sectionLabel "Scene"
    , input
          [ type_ "text"
          , css [ inputStyles ]
          , onInput (UpdateSceneTitle index)
          , value title
          ]
          []
    , editAspectView index aspects
    , defaultButton
          [ onClick (RemoveScene index)
          , css [ marginTop (Css.em 0.5) ]
          ]
          [ text "Remove Scene" ]
    ]


editAspectView : Index -> Array Aspect -> Html Msg
editAspectView sceneIndex aspects =
    div
        [ css
            [ marginTop (Css.em 1) ]
        ]
        [ sectionLabel "Aspects"
        , div [] <|
            Array.toList <|
                Array.indexedMap
                    (aspectInput sceneIndex)
                    aspects
        , defaultButton
            [ onClick (AddNewAspect sceneIndex "")
            , css
                [ marginTop (Css.em 1) ]
            ]
            [ text "Add New Aspect" ]
        ]


aspectInput : Index -> Index -> Aspect -> Html Msg
aspectInput sceneIndex aspectIndex (Aspect title invokes) =
    div
        [ css
            [ displayFlex
            , alignItems center
            ]
        ]
        [ input
            [ type_ "text"
            , css [ inputStyles ]
            , onInput
                (\newTitle ->
                    UpdateAspect
                        sceneIndex
                        aspectIndex
                        (Aspect newTitle invokes)
                )
            , value title
            , placeholder <| "Aspect #" ++ String.fromInt (aspectIndex + 1)
            ]
            []
        , defaultButton
            [ onClick (RemoveAspect sceneIndex aspectIndex)
            , css
                [ marginLeft (Css.em 0.5) ]
            ]
            [ text "Remove" ]
        ]

