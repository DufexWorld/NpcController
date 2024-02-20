local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Package =require(script.Parent.Parent)
local AgentMissions = require(script.Parent["Agent.missions"])

local Remotes = ReplicatedStorage.Remotes.Npcs
local TalkAsync: RemoteFunction = Remotes.TalkAsync
local StopTalkAsync: RemoteFunction = Remotes.TalkStopAsync

local expectType = tostring
local Agent = {}

function Agent:Configure()
   Package.Configure(self)

   self.MissionPackage = AgentMissions[self.Body.Name]
   setmetatable(self, {__index = self.MissionPackage})

   self.Path = nil
   self.Body.HumanoidRootPart.Anchored = true

   local Prompt = Instance.new("ProximityPrompt")
   Prompt.Style = Enum.ProximityPromptStyle.Custom
   Prompt:SetAttribute("Theme", "Talk")
   Prompt.RequiresLineOfSight = false
   Prompt.HoldDuration = .6
   Prompt.Parent = self.Body.PrimaryPart
   Prompt.ActionText = "Talk with.. ".. self.Body.Name
   Prompt.ObjectText = ""
   
   self.ProximityPrompt = Prompt
   self.Humanoid.MaxHealth = math.huge
   self.Humanoid.Health = math.huge
   self.Humanoid.RequiresNeck = false

   local Animations = self.Class.Animations
   local Idle = Animations.Idle

   local Animation = Instance.new("Animation")
   Animation.AnimationId = Idle

   local IdleTrack: AnimationTrack = self.Humanoid:LoadAnimation(Animation)
   IdleTrack.Priority = Enum.AnimationPriority.Action4
   IdleTrack.Looped = true
   task.defer(function()
      repeat
         IdleTrack:Play()
         task.wait(.1)
      until not IdleTrack.IsPlaying
   end)

   local Head: BasePart = self.Body.Head
   local BodyNameDisplay: TextLabel = Head.GuiName.Label
   local AgentName: string = BodyNameDisplay.Text

   Prompt.TriggerEnded:Connect(function(playerWhoTriggered)
      local PlayerMission = self:GetPlayerMission(playerWhoTriggered.Data)
      assert(PlayerMission, `Mission data not valid for {playerWhoTriggered.Name}, user data, {playerWhoTriggered.Data}`)
      PlayerMission:TalkWithPlayer(playerWhoTriggered, Remotes.TalkAsync)
   end)

   self.Humanoid:SetAttribute("CanBeDamaged", false)
   if expectType(self.MissionPackage) == "find-item" then
      warn("ok")
      self:AsyncItem()
   else
      warn("no")
   end
end

return Agent