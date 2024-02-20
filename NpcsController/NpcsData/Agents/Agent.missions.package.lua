local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Agent = {}

local PlayersService = require(ReplicatedStorage.Codes.Libraries.PlayerService)

local expectType = tostring

local Remotes = ReplicatedStorage.Remotes.Mission
local CancelMissionRemote: RemoteEvent = Remotes.Cancel

function Agent:IsPlayerAvaliable(class)
   return not class.Mission:GetAttribute("Avaliable")
end

function Agent:IsPlayerConcludeMission(class, MissionName)
   return class.MissionsConcludes:GetAttribute(MissionName) ~= nil
end

function Agent:PlayerIsOnMission(class, missionName)
   return class.Mission:GetAttribute("NpcName") == missionName
end

function Agent:GetPlayerMission(class)      
   for _, Mission in self.MissionPackage do
      if expectType(Mission) ~= "mission" then continue end
      if class.MissionsConcludes:GetAttribute(Mission.Name or "") == nil then
         return Mission
      end
   end
end

CancelMissionRemote.OnServerEvent:Connect(function(player)
   local data = PlayersService.GetPlayerClass(player)
   assert(data, "Player data was invalid!")

   data:RemoveMission()
end)

return Agent 