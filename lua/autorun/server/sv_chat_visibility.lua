util.AddNetworkString( "CFC_ChatVisibility_print" )
local colors = {
    team_label     = Color( 0, 255, 0 ),
    psay_seperator = Color( 0, 180, 90 ),
    text           = Color( 255, 255, 255 )
}

local format = string.format

local function isStaff( ply )
    return ply:IsAdmin()
end

local function teamColor( ply )
    return team.GetColor( ply:GetTeam() )
end

local function printMessage( ply, msg )
    net.Start( "CFC_ChatVisibility_print" )
    net.WritTable( msg )
    net.Send( ply )
end

local function printStaff( msg )
    for _, ply in pairs( player.GetHumans() ) do
        if isStaff( ply ) and msg:shouldPrint( ply ) then
            printMessage( ply, msg )
        end
    end

end


hook.Add( "PlayerSay", "CFC_ChatVisibility_Say", function( ply, text, isTeam )
    if not isTeam then return end

    local message = {
        author = ply,
        message = {
            colors.team_label, "(team)",
            teamColor( ply ), ply:GetName(),
            colors.text ":", text
        },
        msgType = "TEAM",
        shouldPrint = function( msg, ply )
            return msg.author:GetTeam() ~= ply:GetTeam()
        end
    }

    printStaff( message )
end) 

hook.Add( "ULibCommandCalled", "CFC_ChatVisibility_ULibCommand", function( ply, cmd, args )
    if cmd ~= "ulx psay" then return end
    author    = args[1]
    recipient = args[2]
    text      = args[3]

    printStaff{
        author = author,
        recipient = recipient,
        message = {
            teamColor( author ), author:GetName(),
            colors.psay_seperator, "->",
            teamColor( recipient ), recipient:GetName(),
            colors.text, ":", text
        },
        msgType = "PSAY",
        shouldPrint = function( msg, ply )
            return msg.author ~= ply and msg.recipient ~= ply
        end
    }

end)
