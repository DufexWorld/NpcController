local catalog = {}

local __missionsBaseData = {
   MissionName = "any",
   Description = "any",
   TurnProgressInvisible = false
}

function catalog:__missionFindItem()
   return "find-item"
end

function catalog:__missionKill()
   return "kill-npc"
end

function catalog:__mission()
   return "mission"
end

function catalog.reconcileMission(rewrite: mission)
   rewrite = rewrite or {}

   for name, value in __missionsBaseData do
      rewrite[name] = rewrite[name] or value
   end

   return rewrite
end

function catalog.toFolder(dataArray)
   local folder = Instance.new("Folder")

   for name, value in dataArray do
      if type(value) == "function" or type(value) == "thread" then continue end

      if type(value) == "table" then
         local newFolder = catalog.toFolder(value)
         newFolder.Name = name
         newFolder.Parent = folder
         continue
      end

      folder:SetAttribute(name, value)
   end

   return folder   
end

type mission = typeof(__missionsBaseData)

return catalog