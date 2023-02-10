LUnboxInventoryAddition = LUnboxInventoryAddition or {}

function LUnboxInventoryAddition:GetPlayerInventory(ply)
    local data = {}

    if file.Exists("invaddition/" .. ply:SteamID64() .. ".txt", "DATA") then
        data = util.JSONToTable(file.Read("invaddition/" .. ply:SteamID64() .. ".txt", "DATA"))
        ply.LUnboxADData = data
    else
        data = {}
        ply.LUnboxADData = data
    end
end

function LUnboxInventoryAddition:AddWeapon(ply, weapon)
    local data = ply.LUnboxADData
    if LUnboxInventoryAddition:HasWeapon(ply, weapon) then
        data[weapon].amount = LUnboxInventoryAddition:GetItemAmount(ply, weapon) + 1
        file.Write("invaddition/" .. ply:SteamID64() .. ".txt", util.TableToJSON(data))
        LUnboxInventoryAddition:SendInventory(ply)

    else
        data[weapon] = {}
        data[weapon].name = weapon
        data[weapon].amount = 1
        file.Write("invaddition/" .. ply:SteamID64() .. ".txt", util.TableToJSON(data))
        LUnboxInventoryAddition:SendInventory(ply)
    end
end

function LUnboxInventoryAddition:RemoveWeapon(ply, weapon)
    local data = ply.LUnboxADData
    print("Removing weapon")
    if data[weapon].amount == 1 then
        data[weapon] = nil
        file.Write("invaddition/" .. ply:SteamID64() .. ".txt", util.TableToJSON(data))
        LUnboxInventoryAddition:SendInventory(ply)
    end
    if data[weapon] then
        data[weapon].amount = LUnboxInventoryAddition:GetItemAmount(ply, weapon) - 1
    end
end

function LUnboxInventoryAddition:HasWeapon(ply, weapon)
    local data = ply.LUnboxADData
    return data[weapon]
end

function LUnboxInventoryAddition:GetItemAmount(ply, weapon)
    local data = ply.LUnboxADData
    for k,v in pairs(data) do
        if k == weapon then
            return v.amount
        end
    end
end


function LUnboxInventoryAddition:ClearInventory(ply)
    file.Write("invaddition/" .. ply:SteamID64() .. ".txt", util.TableToJSON({}))
end


local suitsproper = {
    ["Tier 4"] = true,
    ["Admin Suit V2"] = true,
    ["Godly Armour"] = true,
    ["Tier God"] = true,
    ["Horror Suit Tier 2"] = true,
    ["Tier 3"] = true,
    ["Tier Ultra God"] = true,
    ["Santa Suit"] = true,
    ["Tier 1"] = true,
    ["Tier 2"] = true,
    ["Admin Suit"] = true,
    ["Horror Suit Tier 3"] = true,
    ["Compensation Suit"] = true,
    ["Elf Suit"] = true,
    ["Tier God Slayer"] = true,
    ["Tier Fallen God"] = true,
    ["Horror Suit"] = true,
    ["Flash Suit"] = true,
    ["Tier 5"] = true
}
function LUnboxInventoryAddition:IsSuit(ply, weapon)
    if suitsproper[weapon] then return true end
end

function LUnboxInventoryAddition:WeaponEquip(ply, weapon)
    if LUnboxInventoryAddition:HasWeapon(ply, weapon) then
        LUnboxInventoryAddition:RemoveWeapon(ply, weapon)
        if LUnboxInventoryAddition:IsSuit(ply, weapon) then
            LUnboxInventoryAddition:EntityGive(ply, weapon)
            LUnboxInventoryAddition:SendInventory(ply)
            ply:ChatPrint("{!You have put your suit in ur inv!}")
            return 
        end
        ply:Give(weapon)
        LUnboxInventoryAddition:SendInventory(ply)
    end
end

function LUnboxInventoryAddition:EntityGive(ply, weapon)
    if LUnboxInventoryAddition:HasWeapon(ply, weapon) then
        LUnboxInventoryAddition:RemoveWeapon(ply, weapon)
    else
        ply:ChatPrint("{!You don't have this weapon in your inventory!}")
    end

    data = VNP.Inventory:CreateItem(weapon, "Common")
    ply:AddInventoryItem(data)
    data = VNP.Inventory:CreateItem(weapon, "Common")
    ply:AddInventoryItem(data)
    LUnboxInventoryAddition:SendInventory(ply)
end

function LUnboxInventoryAddition:SendInventory(ply)
    net.Start("LUnboxInventoryAddition:GetInventory")
    net.WriteTable(ply.LUnboxADData)
    net.Send(ply)
end

util.AddNetworkString("LUnboxInventoryAddition:WeaponEquip")
util.AddNetworkString("LUnboxInventoryAddition:EntityGive")
util.AddNetworkString("LUnboxInventoryAddition:GetInventory")

hook.Add("PlayerInitialSpawn", "LUnboxInventoryAddition:PlayerInitialSpawn", function(ply)
    if not file.Exists("invaddition/" .. ply:SteamID64() .. ".txt", "DATA") then
        file.Write("invaddition/" .. ply:SteamID64() .. ".txt", util.TableToJSON({}))
    end

    timer.Simple(4, function()
        LUnboxInventoryAddition:GetPlayerInventory(ply)
        LUnboxInventoryAddition:SendInventory(ply)
    end)
end)

net.Receive("LUnboxInventoryAddition:WeaponEquip", function(len, ply)
    local weapon = net.ReadString()
    LUnboxInventoryAddition:WeaponEquip(ply, weapon)
end)