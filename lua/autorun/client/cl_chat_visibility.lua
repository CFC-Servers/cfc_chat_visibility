net.receive( "CFC_ChatVisibility_print", function(n)
    msgInfo = net.ReadTable()
    chat.AddText( msgInfo.message )
end)