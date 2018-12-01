module API
    exposing
    ( register
    , login
    , logout
    , getAllGames
    , newGame
    , createInvite
    , joinGame
    , getPlayers
    , ping
    , setPresenceOnline
    , setPresenceOffline
    , sendChatMessage
    , getChatLog
    )

import Http
import Json.Decode exposing (decodeValue)
import Json.Encode exposing (encode)
import Lobby.Types as Lobby
import Login.Types as Login
import Game.Types as Game
import Invite
import Game.Decode
    exposing
        ( decodeGameId
        , decodeGameList
        , gameIdDecoder
        , gameListDecoder
        , playerListDecoder
        , chatMessageListDecoder
        )
import Game.Encode exposing ( encodeChatMessage )
import RemoteData exposing (RemoteData(..), WebData)

domain =
    "/api"


getAllGames : Cmd Lobby.Msg
getAllGames =
    let
        request =
            Http.request
                { method = "GET"
                , headers = []
                , url = domain ++ "/games"
                , body = Http.emptyBody
                , expect = Http.expectJson gameListDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        RemoteData.sendRequest request
            |> Cmd.map Lobby.SetGameList


newGame : String -> Cmd Lobby.Msg
newGame title =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++ "/games"
                , body = Http.jsonBody (Json.Encode.string title)
                , expect = Http.expectJson gameIdDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        RemoteData.sendRequest request
            |> Cmd.map (always Lobby.GetGameList)


login : Login.Auth -> Cmd Login.ConsumerMsg
login auth =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++ "/login"
                , body = Http.jsonBody (Login.encodeAuth auth)
                , expect = Http.expectJson Json.Decode.int
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send Login.LoginResponse request
            |> Cmd.map Login.LocalMsg


register : Login.Registration -> Cmd Login.ConsumerMsg
register reg =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++ "/register"
                , body = Http.jsonBody (Login.encodeRegistration reg)
                , expect = Http.expectJson Json.Decode.int
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send Login.RegisterResponse request
            |> Cmd.map Login.LocalMsg


logout : Cmd Lobby.Msg
logout =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++ "/logout"
                , body = Http.emptyBody
                , expect = Http.expectString
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send Lobby.LogoutResponse request

createInvite : Game.GameId -> Cmd Game.Msg
createInvite gameId =
    let
        request =
            Http.request
                { method = "PUT"
                , headers = []
                , url = domain ++ "/games/" ++ gameId ++ "/invite"
                , body = Http.emptyBody
                , expect = Http.expectJson Json.Decode.string
                , timeout = Nothing
                , withCredentials = False
                }
    in
        RemoteData.sendRequest request
            |> Cmd.map Game.InviteCreated

joinGame : String -> Cmd Invite.Msg
joinGame inviteId =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++ "/invite/" ++ inviteId
                , body = Http.emptyBody
                , expect = Http.expectJson gameIdDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send (Invite.JoinGame inviteId) request

getPlayers : Game.GameId -> Cmd Game.Msg
getPlayers gameId =
    let
        request =
            Http.request
                { method = "GET"
                , headers = []
                , url = domain ++ "/games/" ++ gameId ++ "/players"
                , body = Http.emptyBody
                , expect = Http.expectJson playerListDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        RemoteData.sendRequest request
            |> Cmd.map (Game.PlayerList gameId)

ping : Game.GameId -> Cmd Game.Msg
ping gameId =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++ "/games/" ++ gameId ++ "/ping"
                , body = Http.emptyBody
                , expect = Http.expectString
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send (always Game.Pong) request

setPresenceOffline : Game.GameId -> Cmd Game.Msg
setPresenceOffline gameId =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++
                        "/games/" ++ gameId ++
                        "/presence/" ++ "offline"
                , body = Http.emptyBody
                , expect = Http.expectString
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send (always Game.NoOp) request

setPresenceOnline : Game.GameId -> Cmd Game.Msg
setPresenceOnline gameId =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++
                        "/games/" ++ gameId ++
                        "/presence/" ++ "online"
                , body = Http.emptyBody
                , expect = Http.expectString
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send (always Game.NoOp) request


sendChatMessage : Game.GameId
                -> Game.NewChatMessage
                -> Cmd Game.Msg
sendChatMessage gameId chatMessage =
    let
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = domain ++ "/games/" ++ gameId ++ "/chat"
                , body =
                    Http.jsonBody
                        (encodeChatMessage chatMessage)
                , expect = Http.expectString
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send (always Game.NoOp) request


getChatLog : Game.GameId -> Cmd Game.Msg
getChatLog gameId =
    let
        request =
            Http.request
                { method = "GET"
                , headers = []
                , url = domain ++ "/games/" ++ gameId ++ "/chat"
                , body = Http.emptyBody
                , expect = Http.expectJson chatMessageListDecoder
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send Game.ChatLogReceived request
