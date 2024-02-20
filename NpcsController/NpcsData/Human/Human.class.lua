local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Package = require(script.Parent.Parent)
local Texts = require(script.Parent["Human.chat"])
local Signals = require(script.Parent.Parent.Parent.Parent.Signals)
local State = require(script.Parent.Parent.Parent.Parent.States)

local Remotes = ReplicatedStorage.Remotes.Npcs
local TalkAsync: RemoteFunction = Remotes.TalkAsync

local Human = setmetatable({}, {__index = Package})
local maxDistance = 50

local RunAnimation = Instance.new("Animation")
RunAnimation.AnimationId = "rbxassetid://15938345724"

local function getRandomPosition(start, min, max)
   return start + Vector3.new(
      math.random(min, max),
      math.random(min/3, max/3),
      math.random(min, max)
   )
end

function Human:Configure()
   Package.Configure(self)
   local OnPanic = State.new(false)
   local Humanoid = self.Humanoid

   self.OnPanic = OnPanic
   self.OnPanic.alwaysProtect = true
   self.target = getRandomPosition(self.Humanoid.RootPart.Position, -maxDistance, maxDistance)
   self.Path.Visualize = false

   self.Path.Blocked:Connect(function()
      if self.IsTalking then return end
      self.Path:Run(self.target)
   end)

   self.Path.Error:Connect(function(errorType)
      if self.IsTalking then return end

      self.target = getRandomPosition(self.Humanoid.RootPart.Position, -maxDistance, maxDistance)
      self.Path:Run(self.target)
   end)

   self.Path.Reached:Connect(function()
      if self.IsTalking then return end

      task.wait(math.random(3,10))
      self.target = getRandomPosition(self.Humanoid.RootPart.Position, -maxDistance, maxDistance)
      self.Path:Run(self.target)
   end)

   self.Path:Run(self.target)

   self.IsTalking = false
   self.Talk = Signals.new("Talk")
   self.StopTalk = Signals.new("StopTalk")

   local Prompt = Instance.new("ProximityPrompt")
   Prompt.Parent = self.Body.PrimaryPart
   Prompt.ClickablePrompt = false
   Prompt.ActionText = "Talk with ".. self.CharacterName.Name
   Prompt.KeyboardKeyCode = Enum.KeyCode.F
   Prompt.MaxActivationDistance = 6
   Prompt.HoldDuration = 1
   Prompt.RequiresLineOfSight = false

   Prompt.TriggerEnded:Connect(function(playerWhoTriggered)
      self.TalkingPlayer = playerWhoTriggered
      self.Talk:Fire(playerWhoTriggered)
   end)

   self.Talk:Connect(function(Player: Player)
      if self.IsTalking then
         return
      end

      warn("status is:", self.Path._status)

      local conversationStart = os.clock()
      local connection;
      
      task.defer(function()
         while task.wait() do
            if math.abs(conversationStart-os.clock()) > 10 then
               connection:Disconnect()
               self.IsTalking = false
               self.Path:Run(self.target)
               if Player.Parent == Players then Remotes.TalkStopAsync:InvokeClient(self.TalkingPlayer) end
               break
            end
         end    
      end)

      local Character = Player.Character
      local Humanoid = Character.Humanoid
            
      repeat
         self.Path:Stop()
         TweenService:Create(
            self.Body.PrimaryPart,
            TweenInfo.new(.15,Enum.EasingStyle.Linear),
            {
               CFrame = CFrame.lookAt(
                  self.Body.PrimaryPart.Position,
                  Vector3.new(
                     Character.PrimaryPart.Position.X,
                     self.Body.PrimaryPart.Position.Y,
                     Character.PrimaryPart.Position.Z
                  )
               )
            }
         ):Play()
         task.wait()
      until self.Path._status == "Idle"
      
      connection = Humanoid.Running:Connect(function()
         if (Character.PrimaryPart.Position - self.Body.PrimaryPart.Position).Magnitude > 7 then
            self.Path:Run(self.target)
            self.IsTalking = false
            connection:Disconnect()
         end
      end)

      self.OnPanic:observe(function(newState)
         if self.Humanoid.Health <= 0 then return pcall(self.OnPanic.remove, self.OnPanic) end

         if newState and self.TalkingPlayer then
            Remotes.TalkStopAsync:InvokeClient(self.TalkingPlayer)
         end
      end)

      local Result = TalkAsync:InvokeClient(Player, {
         Name = self.CharacterName.Name,
         Content = Texts[math.random(1, #Texts)]
      })

      warn(Result)

      self.Path:Run(self.target)
      self.IsTalking = false
      connection:Disconnect()
   end)

   local RunKeyFrame = Humanoid:LoadAnimation(RunAnimation)
   local HumanoidHealth = Humanoid.Health

   Humanoid.HealthChanged:Connect(function(health)
      print("changed", health, health > HumanoidHealth)
      if HumanoidHealth > health then
         print("damaged")
         OnPanic.lastHit = os.time()
         HumanoidHealth = health
         if not OnPanic:get() and not RunKeyFrame.IsPlaying then
            RunKeyFrame:Play(.15)
            OnPanic:set(true)
         end
      end
   end)
   
   OnPanic:observe(function(newValue: boolean)
      if self.Humanoid.Health <= 0 then return pcall(self.OnPanic.remove, self.OnPanic) end

      if newValue then
         Humanoid.WalkSpeed = self.Class.RunSpeed
         self.Path:Run(getRandomPosition(self.Body.PrimaryPart.Position, -100, 100))
         OnPanic.start = os.time()
         
         print("panic started")
         while RunService.Heartbeat:Wait() do
            if math.abs(OnPanic.start - os.time()) <= 4 then continue end
            OnPanic:set(false)
            break
         end
      else
         print("panic stopped")
         Humanoid.WalkSpeed = self.Class.WalkSpeed
         RunKeyFrame:Stop(.25)
         self.Path:Run(self.target)
      end
   end)

   Humanoid.Died:Once(function()
      local body = self.Body

      OnPanic:remove()
      local animator = self.Humanoid.Animator :: Animator
      for _, track in animator:GetPlayingAnimationTracks() do
         track:Stop()
      end

      Prompt:Destroy()
      self.Path:Destroy()
      setmetatable(self, nil)

      task.wait(10)
      body:Destroy()
   end)

end

return Human