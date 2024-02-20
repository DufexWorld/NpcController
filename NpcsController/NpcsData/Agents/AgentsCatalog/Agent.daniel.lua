local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = require(script.Parent.Parent.Parent.Parent.Parent.PlayerService)
local MissionsPackage = require(script.Parent.Parent["Agent.missions.package"])
local Repository = require(script.Parent.FunctionRepository)

local NpcName = "Daniel"
local Agent = setmetatable({Name = NpcName} , {__index = MissionsPackage, __tostring = Repository.__missionKill})

Agent.KillBandits = setmetatable({Name = "CollectTrash",Data = {
   Description = "Collect the trash in the area.",
   MissionName = "Collect trash.",
   TurnProgressInvisible = false,
   NpcTarget = "_Trash",
   NpcKilled = 0,
   NpcsKilledMax = 5,
}}, {
   __index = Agent, 
   __tostring = Repository.__mission
})

--[[Get item mission, try to find item.]]

function Agent:GetTalkContent()
   return {
      Content = "Hey can you collect some trash for me?",
      Response = "Ahh, okay.."
   }
end

function Agent:FirstStage()
   return {
      Content = "I collected a lot, is it useful?",
      Response = "..."
   }
end

function Agent:RemoveMission(PlayerData)
   PlayerData.Mission:SetAttribute("Name", "")
   PlayerData.Mission:SetAttribute("Avalaible", false)
   for name, _ in PlayerData.Mission.MissionData:GetAttributes() do
      PlayerData.Mission.MissionData:SetAttribute(name, nil)
   end
end

function Agent:OnConclude(player: Player)
   local PlayerData = player.Data
   Agent:RemoveMission(PlayerData)
   --PlayerData.MissionsConcludes:SetAttribute(self.KillBandits.Name, true)
   PlayerData.PlayerData:SetAttribute("Exp", PlayerData.PlayerData:GetAttribute("Exp") + 250)
   PlayerData.PlayerData:SetAttribute("Cash", PlayerData.PlayerData:GetAttribute("Cash") + 100)
end

function Agent:AsyncMissionData(data: PackageFolder)
   local dataValue = self.KillBandits.Data
   local converted = Repository.toFolder(dataValue)
   converted.Name = self.KillBandits.Name
   converted.Parent = data.Mission.MissionData
end

function Agent:TalkWithPlayer(player, remoteAsync: RemoteFunction)
   local playerKilledTheNpcs = player.Data.Mission.MissionData:GetAttribute("NpcKilled")
   if playerKilledTheNpcs then
      playerKilledTheNpcs = playerKilledTheNpcs >= player.Data.Mission.MissionData:GetAttribute("NpcsKilledMax")
   end

   if Agent:IsPlayerConcludeMission(player.Data, self.KillBandits.Name) then
      warn("Player conclued that")
      return
   end

   if playerKilledTheNpcs and not self:IsPlayerConcludeMission(player.Data, self.KillBandits.Name) then
      local result= remoteAsync:InvokeClient(player, {Name = NpcName, Content = self:FirstStage()}) 
      if result then
         Agent:OnConclude(player)
      end
   elseif not Agent:PlayerIsOnMission(player.Data, "Lucky") then
      local result = remoteAsync:InvokeClient(player, {Name = NpcName, Content = self:GetTalkContent()}) 
      if result then
         PlayerService.GetPlayerClass(player):SetMission({
            Mission = {Avaliable = true, NpcName = NpcName},
            MissionData = self.KillBandits.Data
         })
      end
   else
      remoteAsync:InvokeClient(player, {Name = NpcName, Content = {
         Content = "Only talk with me when conclude that!",
         Response = "..."
      }})
   end
end

type PlayerData =  typeof(PlayerService.GetPlayerClass())
type PackageData<k, v> = {[k]: v}
type PackageFolder = Folder & PackageData<string, Model>

return Agent