net.Receive( "CFC_ChatVisibility_print", function(n)
    message = net.ReadTable()
    chat.AddText( unpack( message ) )
end)
