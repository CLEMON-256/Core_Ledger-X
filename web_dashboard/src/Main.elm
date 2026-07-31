port module Main exposing (..)

import Browser
import Html exposing (Html, div, text, h2, table, tr, th, td, h3, button, strong, span)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


-- 1. SAAS ARCHITECTURE TYPES (Tenants & Subscription Plans)

type SubscriptionTier
    = FreeTier
    | EnterpriseTier

type alias TenantInfo =
    { name : String
    , domainId : String
    , plan : SubscriptionTier
    }

type alias Transaction =
    { id : String
    , amount : Float
    , status : String
    }

type alias Model =
    { activeTenant : TenantInfo
    , transactions : List Transaction
    , totalProcessed : Float
    , threatsFlagged : Int
    }


-- INITIAL MULTI-TENANT STATE

init : () -> ( Model, Cmd Msg )
init _ =
    ( { activeTenant = 
            { name = "Kampala Fintech Corp"
            , domainId = "tenant_0921"
            , plan = FreeTier -- Try toggling this to EnterpriseTier to see layout changes
            }
      , transactions =
          [ { id = "TX-A1111", amount = 150.00, status = "SAFE" }
          , { id = "TX-ALERT", amount = 999999.90, status = "CRITICAL" }
          ]
      , totalProcessed = 1000149.90
      , threatsFlagged = 1
      }
    , Cmd.none
    )


-- 2. SAAS UPDATE ACTIONS (Handling Subscription and Port Upgrades)

type Msg
    = UpgradeClicked
    | ReceivedExternalTenantUpgrade String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpgradeClicked ->
            -- Fire an asynchronous command to the browser to launch a payment checkout link
            ( model, requestPaymentCheckout model.activeTenant.domainId )

        ReceivedExternalTenantUpgrade newTier ->
            -- Securely handle webhook events piped back from Stripe via Ports
            let
                currentTenant = model.activeTenant
                updatedTenant = 
                    if newTier == "ENTERPRISE" then
                        { currentTenant | plan = EnterpriseTier }
                    else
                        currentTenant
            in
            ( { model | activeTenant = updatedTenant }, Cmd.none )


-- 3. SAAS EXTERNAL PORTS FRAMEWORK

-- Outbound: Asks JavaScript to open a Stripe session or portal
port requestPaymentCheckout : String -> Cmd msg

-- Inbound: Receives push notifications from JavaScript when payment clears
port listenTenantUpgrades : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    listenTenantUpgrades ReceivedExternalTenantUpgrade


-- 4. SAAS CONDITIONALLY RENDERED DASHBOARD UI

view : Model -> Html Msg
view model =
    div [ style "font-family" "sans-serif", style "padding" "30px", style "background" "#f4f6f9", style "min-height" "100vh" ]
        [ -- SaaS Multi-Tenant Header Guard
          div [ style "background" "#2c3e50", style "padding" "15px 25px", style "color" "white", style "border-radius" "6px", style "display" "flex", style "justify-content" "between", style "align-items" "center", style "margin-bottom" "25px" ]
            [ div []
                [ h2 [ style "margin" "0" ] [ text ("SaaS Control: " ++ model.activeTenant.name) ]
                , div [ style "font-size" "12px", style "opacity" "0.8" ] [ text ("ID: " ++ model.activeTenant.domainId) ]
                ]
            , renderPlanBadge model.activeTenant.plan
            ]
        
        -- Tiered SaaS Analytics Access Rules
        , div [ style "display" "flex", style "gap" "20px", style "margin-bottom" "30px" ]
            [ renderMetricCard "Total Volume Settled" ("$" ++ String.fromFloat model.totalProcessed) "#2ecc71"
            , case model.activeTenant.plan of
                EnterpriseTier ->
                    renderMetricCard "AI Security Threats Flagged" (String.fromInt model.threatsFlagged) "#e74c3c"
                FreeTier ->
                    -- Block premium metrics on lower tiers to upsell users
                    div [ style "background" "#dfe6e9", style "padding" "20px", style "border-radius" "8px", style "flex" "1", style "text-align" "center", style "border" "2px dashed #b2bec3" ]
                        [ strong [ style "color" "#2d3436" ] [ text "🔒 AI Threat Guard Locked" ]
                        , div [ style "font-size" "12px", style "margin" "10px 0", style "color" "#636e72" ] [ text "Upgrade to Enterprise to track anomalies in real-time." ]
                        , button [ onClick UpgradeClicked, style "background" "#e67e22", style "color" "white", style "border" "none", style "padding" "5px 12px", style "border-radius" "4px", style "cursor" "pointer" ] [ text "Unlock Layer" ]
                        ]
            ]
            
        -- Data Grid
        , div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 2px 4px rgba(0,0,0,0.05)" ]
            [ h3 [] [ text "Polyglot Pipeline Stream (Filtered by Tenant Account Space)" ]
            , table [ style "width" "100%", style "border-collapse" "collapse", style "margin-top" "15px" ]
                [ tr [ style "background" "#f8f9fa", style "border-bottom" "2px solid #dee2e6", style "text-align" "left" ]
                    [ th [ style "padding" "12px" ] [ text "Transaction Hash" ]
                    , th [ style "padding" "12px" ] [ text "Amount" ]
                    , th [ style "padding" "12px" ] [ text "Threat Vector Rating" ]
                    ]
                , Html.tbody [] (List.map (renderTxRow model.activeTenant.plan) model.transactions)
                ]
            ]
        ]


-- COMPONENT HELPER FUNCTIONS

renderPlanBadge : SubscriptionTier -> Html Msg
renderPlanBadge tier =
    case tier of
        EnterpriseTier ->
            span [ style "background" "#9b59b6", style "padding" "6px 12px", style "border-radius" "20px", style "font-size" "12px", style "font-weight" "bold" ] [ text "ENTERPRISE PLAN" ]
        FreeTier ->
            span [ style "background" "#7f8c8d", style "padding" "6px 12px", style "border-radius" "20px", style "font-size" "12px", style "font-weight" "bold" ] [ text "FREE DEVELOPER TIER" ]

renderMetricCard : String -> String -> String -> Html Msg
renderMetricCard title value color =
    div [ style "background" "white", style "padding" "20px", style "border-radius" "8px", style "box-shadow" "0 2px 4px rgba(0,0,0,0.05)", style "flex" "1" ]
        [ h3 [ style "margin" "0", style "color" "#666", style "font-size" "14px" ] [ text title ]
        , div [ style "font-size" "24px", style "font-weight" "bold", style "color" color, style "margin-top" "10px" ] [ text value ]
        ]

renderTxRow : SubscriptionTier -> Transaction -> Html Msg
renderTxRow tier tx =
    let
        ( displayStatus, statusColor ) =
            case ( tier, tx.status ) of
                ( FreeTier, "CRITICAL" ) ->
                    ( "[LOCKED]", "#7f8c8d" )
                ( _, "CRITICAL" ) ->
                    ( tx.status, "#e74c3c" )
                _ ->
                    ( tx.status, "#2ecc71" )
    in
    tr [ style "border-bottom" "1px solid #dee2e6", style "height" "45px" ]
        [ td [ style "padding" "12px" ] [ text tx.id ]
        , td [ style "padding" "12px" ] [ text ("$" ++ String.fromFloat tx.amount) ]
        , td [ style "padding" "12px", style "color" statusColor, style "font-weight" "bold" ] [ text displayStatus ]
        ]


-- ENTRY DEFINITION

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
