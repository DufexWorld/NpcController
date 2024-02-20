local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = require(script.Parent.Parent.Parent.Parent.Parent.PlayerService)
local MissionsPackage = require(script.Parent.Parent["Agent.missions.package"])
local Repository = require(script.Parent.FunctionRepository)

local Agent = setmetatable({Name = "Mike"} , {__index = MissionsPackage, __tostring = Repository.__missionFindItem})

Agent.GetMySword = setmetatable({Name = "GetMySword",Data = {
   Description = "Find mike sword",
   MissionName = "Find Sword",
   TurnProgressInvisible = true
}}, {
   __index = Agent, 
   __tostring = Repository.__mission
})

local PlayerAttributeName = "MikeSwordIsFinded"
local MissionItems: PackageFolder = workspace:WaitForChild("MissionItems"):WaitForChild("Mike")

--[[Get item mission, try to find item.]]

function Agent:GetTalkContent()
   return {
      Content = "Hey can you get my sword for me??",
      Response = "Alright."
   }
end

function Agent:FirstStage()
   return {
      Content = "Thank you for find my dick.",
      Response = "Your welcome!"
   }
end

function Agent:OnConclude(player: Player)
   local PlayerData = player.Data
   Agent:RemoveMission(PlayerData)
   --PlayerData.MissionsConcludes:SetAttribute(self.GetMySword.Name, true)
   PlayerData.PlayerData:SetAttribute("Exp", PlayerData.PlayerData:GetAttribute("Exp") + 100)
   PlayerData.PlayerData:SetAttribute("Cash", PlayerData.PlayerData:GetAttribute("Cash") + 15)
end

function Agent:AsyncMissionData(data: PackageFolder)
   local dataValue = self.GetMySword.Data
   local converted = Repository.toFolder(dataValue)
   converted.Name = self.GetMySword.Name
   converted.Parent = data.Mission.MissionData
end

function Agent:TalkWithPlayer(player, remoteAsync: RemoteFunction)
   local PlayerFindedTheSword = player:GetAttribute(PlayerAttributeName)

   if Agent:IsPlayerConcludeMission(player.Data, self.GetMySword.Name) then
      warn("Player conclued that")
      return
   end

   if PlayerFindedTheSword and not self:IsPlayerConcludeMission(player.Data, self.GetMySword.Name) then
      local result= remoteAsync:InvokeClient(player, {Name = "Mike", Content = self:FirstStage()}) 
      if result then
         player:SetAttribute(PlayerAttributeName, nil)
         Agent:OnConclude(player)
      end
   elseif not Agent:PlayerIsOnMission(player.Data, "Mike") then
      local result = remoteAsync:InvokeClient(player, {Name = "Mike", Content = self:GetTalkContent()}) 
      if result then
         PlayerService.GetPlayerClass(player):SetMission({
            Mission = {Avaliable = true, NpcName = "Mike"},
            MissionData = {
               TurnProgressInvisible = true,
               Description = self.GetMySword.Data.Description,
               MissionName = self.GetMySword.Data.MissionName
            }
         })       
      end
   else
      remoteAsync:InvokeClient(player, {Name = "Mike", Content = {
         Content = "Go!",
         Response = "Vai tomar no cu arrombado!"
      }})
   end
end

function Agent:AsyncItem()
   local Sword: Model = MissionItems:FindFirstChild("Sword")
   assert(Sword.PrimaryPart, "Sword primary part is necessary")

   local ProximityPrompt = Instance.new("ProximityPrompt")
   ProximityPrompt.HoldDuration = .6
   ProximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
   ProximityPrompt.ActionText = ""
   ProximityPrompt.ObjectText = ""
   ProximityPrompt.MaxActivationDistance = 10
   ProximityPrompt.Parent = Sword.PrimaryPart

   ProximityPrompt.TriggerEnded:Connect(function(playerWhoTriggered)
      if Agent:PlayerIsOnMission(playerWhoTriggered.Data, Agent.Name) then
         ReplicatedStorage.Remotes.Notification:FireClient(playerWhoTriggered, "Go to mike.")
         playerWhoTriggered:SetAttribute(PlayerAttributeName, true)
      end
   end)
end

type PlayerData =  typeof(PlayerService.GetPlayerClass())
type PackageData<k, v> = {[k]: v}
type PackageFolder = Folder & PackageData<string, Model>

return Agent