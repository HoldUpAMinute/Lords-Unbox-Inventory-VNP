net.Receive("LUnboxInventoryAddition:GetInventory", function()
    local var = net.ReadTable()
    LocalPlayer().PlayerItemInventory = var
    LUnbox:OpenMenu()
end)