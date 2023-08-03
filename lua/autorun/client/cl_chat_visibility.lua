local enabledConvar = CreateClientConVar( "cfc_chatvisibility_enabled", "1", true, false )

net.Receive( "CFC_ChatVisibility_print", function()
    if not enabledConvar:GetBool() then return end

    message = net.ReadTable()
    chat.AddText( unpack( message ) )
end )
