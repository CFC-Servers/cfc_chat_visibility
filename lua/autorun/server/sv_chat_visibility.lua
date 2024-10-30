util.AddNetworkString( "CFC_ChatVisibility_print" )
local colors = {
    team_label     = Color( 24, 162, 35 ),
    psay_seperator = Color( 0, 180, 90 ),
    text           = Color( 255, 255, 255 )
}

local teamchatCvar = CreateConVar("chatvisibility_logteamchat", "1", {FCVAR_ARCHIVE}, "Should team messages automatically be forwarded to staff?")
ULib.ucl.registerAccess( "ulx seepsay", ULib.ACCESS_ADMIN, "Ability to see all team and private messages", "Other" )

local function canSee( ply )
    return ULib.ucl.query( ply, "ulx seepsay" ) == true
end

local function teamColor( ply )
    return team.GetColor( ply:Team() )
end

local function printMessage( ply, msg )
    net.Start( "CFC_ChatVisibility_print" )
    net.WriteTable( msg )
    net.Send( ply )
end

local function printStaff( msg )
    for _, ply in pairs( player.GetHumans() ) do
        if canSee( ply ) and msg:shouldPrint( ply ) then
            printMessage( ply, msg.message )
        end
    end
end


hook.Add( "PlayerSay", "CFC_ChatVisibility_Say", function( author, text, isTeam )
    if not isTeam then return end
    if not IsValid( author ) then return end
    if not teamchatCvar:GetBool() then return end

    printStaff{
        author = author,
        message = {
            colors.team_label, "(TEAM) ",
            teamColor( author ), author:GetName(),
            colors.text, ": ", text
        },
        msgType = "TEAM",
        shouldPrint = function( msg, ply )
            return msg.author:Team() ~= ply:Team()
        end
    }
end )

hook.Add( "ULibPostTranslatedCommand", "CFC_ChatVisibility_ULibCommand", function( _, cmd, args )
    if cmd ~= "ulx psay" then return end
    local author    = args[1]
    local recipient = args[2]
    local text      = args[3]
    if not IsValid( author ) then return end
    if not IsValid( recipient ) then return end

    printStaff{
        author = author,
        recipient = recipient,
        message = {
            teamColor( author ), author:GetName(),
            colors.psay_seperator, " ➔ ",
            teamColor( recipient ), recipient:GetName(),
            colors.text, ": ", text
        },
        msgType = "PSAY",
        shouldPrint = function( msg, ply )
            return msg.author ~= ply and msg.recipient ~= ply
        end
    }
end )
