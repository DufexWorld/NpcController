local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Cloths = require(script.Parent.Cloths)
local Names = require(script["Characters.names"])
local SimplePath = require(script.Parent.SimplePath)

--//
local methodspackage = {}

--//package
function methodspackage:Configure()
   local SerealCode = HttpService:GenerateGUID(false):sub(1,4)
   local Class = self.Class

   self.Body:SetAttribute("SerealCode", SerealCode)
   self.Body:AddTag(SerealCode)

   if Class.AutoPath then
      self.Path = SimplePath.new(self.Body, {
         AgentCanJump = false,
         Costs = {
            Snow = 3,
            Grass = 0,
            Sand = 1,
            Slate = 5,
            Water = math.huge,
            Blocked = math.huge,
            Neon = math.huge
         }
      })
   end
   
   if Class.AutoName then
      local CharacterName = Names[math.random(1, #Names)]
      local GuiName: BillboardGui = self.Body:FindFirstChild("GuiName", true)
      local Label: TextLabel = GuiName.Label
      Label.Text = CharacterName.Name
      Label.FontFace = Font.fromEnum(Enum.Font.SourceSansBold)
      self.CharacterName = CharacterName
   end

   local Humanoid: Humanoid = self.Humanoid
   
   Humanoid.RequiresNeck = false
   Humanoid.MaxHealth = Class.Health
   Humanoid.Health = Class.MaxHealth
   Humanoid.WalkSpeed = math.random(Class.WalkSpeed/2, Class.WalkSpeed)
   
   self.Parent = methodspackage

   if Class.Cloths then
      self:LoadAnimationsForScript()
      Cloths:applyFor(self.Body)
   end
end

function methodspackage:Run(goal)
   if not goal or self.Path then return warn("not configured") end
   
   self.Path:Run(goal)
end

function methodspackage:Move(position: Vector3, waitForFinish: boolean)
   task.synchronize()
   self.Humanoid:MoveTo(position)
   if waitForFinish then self.Humanoid.MoveToFinished:Wait() end
   task.desynchronize()
end

function methodspackage:Jump()
   task.synchronize()
   local humanoid: Humanoid = self.Humanoid
   if humanoid:GetState() == Enum.HumanoidStateType.Jumping then return task.desynchronize() end
   humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
   task.desynchronize()
end
   
function methodspackage:AnimationConvert(target)
   local package = {}
   local list = target or self.Class.Animations
   local humanoid = self.Body.Humanoid
   local animator = humanoid:FindFirstChild("Animator") or humanoid

   for name, id in list do
      local Animation = Instance.new("Animation")
      Animation.AnimationId = id
      package[name] = animator:LoadAnimation(Animation)
   end

   return package :: {[any]: AnimationTrack}
end

function methodspackage:LoadAnimationsForScript()
   local Class = self.Class
   local Character = self.Body
   local Animate = Character:WaitForChild("Animate")
   
   Animate.walk.WalkAnim.AnimationId = Class.Animations.Walk
   Animate.idle.Animation1.AnimationId = Class.Animations.Idle
   Animate.run.RunAnim.AnimationId = Class.Animations.Run
end

function methodspackage:SortCloth()
   
end

return methodspackage