local HttpService = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")

local States = require(script.Parent.States)
local BaseClass = require(script.NpcsData)
local Spreed = require(script.Parent.Particles)
local PlayerService = require(game.ReplicatedStorage.Codes.Libraries.PlayerService)

--//Npcs controller
local controller = {NpcsClasses = require(script.NpcClasses)}
local npcsCache = {}

PhysicsService:RegisterCollisionGroup("Npcs")
PhysicsService:CollisionGroupSetCollidable("Npcs", "Npcs", false)

function controller.getNpcByHumanoid(Humanoid: Humanoid)
   if not Humanoid:GetAttribute("SerealCode") then return end
   return npcsCache[Humanoid:GetAttribute("SerealCode")]
end

function controller.create(class, characterModel: character)
   assert(class, "class was expected")
   assert(characterModel, "character as expected")

   local character = setmetatable({},  {__index = class.MetaTarget})
   local serealCode = HttpService:GenerateGUID(false):sub(1,6)

   if class.Respawn then
      local spawnPoint = characterModel.Parent
      local clone = characterModel:Clone()
      characterModel.Humanoid.Died:Once(function()
         task.wait(5)
         
         clone.Parent = spawnPoint
         controller.create(class, clone):Configure()
      end)
   end

   character.Class = class
   character.IsAlive = States.new(true)
   character.Body = characterModel :: character
   character.Humanoid = characterModel:WaitForChild("Humanoid", math.huge) :: Humanoid
   character.Humanoid:SetAttribute("ClassName", class.ClassName) --//tagging
   character.Humanoid:AddTag(class.ClassName)
   character.Humanoid:SetAttribute("SerealCode", serealCode)
   character.Humanoid.DisplayName = ""
   character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
   Spreed.fromCharacter(character.Body, "Run")

   task.spawn(function()
      for _, Part: BasePart in characterModel:GetDescendants() do
         if Part:IsA("BasePart") then
            Part.CollisionGroup = "Npcs"
            local Modifier = Instance.new("PathfindingModifier")
            Modifier.Parent = Part
            Modifier.PassThrough = true
         end
      end
   end)

   character.Humanoid.Died:Once(function()
      npcsCache[serealCode] = nil
      character.IsAlive:set(false)
      table.clear(character)
      setmetatable(character, nil)
      
      task.wait(2)
      characterModel:Destroy()
   end)

   npcsCache[serealCode] = npcsCache
   return character
end

type character = Model & {
   Humanoid: Humanoid,
   HumanoidRootPart: BasePart
}
type waypointsList = {[number]: PathWaypoint}

return controller :: typeof(controller) & typeof(BaseClass)