local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Bandit = {}
local BanditCombat = {}


local Libraries = script.Parent.Parent.Parent.Parent
local NpcsKit = script.Parent.Parent

local Package = require(NpcsKit)
local State = require(Libraries.States)
local CombatAnimations = require(script.Parent["Bandit.animations"])
local Overlap = require(Libraries.Overlap)
local Cloths = require(script.Parent.Parent.Parent.Cloths)
local PlayerService = require(Libraries.PlayerService)

local BanditRaycastParamters = RaycastParams.new()
BanditRaycastParamters.FilterDescendantsInstances = {workspace:WaitForChild("Npcs")}

local Remotes = ReplicatedStorage.Remotes.Fight

local Hair = Cloths.Package.Hair
local Face = Cloths.Package.Eyes
local Mouth = Cloths.Package.Mouths

--//
local function isDead(humanoid)
   return humanoid.Health <= 0
end

local function lookAt(character, pos)
   if not character or character.PrimaryPart then return end
   character.PrimaryPart.CFrame = CFrame.lookAt(character.PrimaryPart.Position, pos)
end

local function followPlayer(humanoidTarget: Humanoid)
   local class = {}

   class._canfollow = true

   function class:follow(position: Vector3)
      if not self._canfollow then return end

      humanoidTarget:MoveTo(position)
   end

   function class:stop()
      self._canfollow = false
   end

   function class:resume()
      self._canfollow = true
   end

   humanoidTarget.Died:Once(function()
      table.clear(class)
   end)

   return class
end

local function distance(character, self)
   return (character.PrimaryPart.Position - self.Body.PrimaryPart.Position).Magnitude
end

local function breakBlockPlayer(player)
   player.Character:SetAttribute("Blocking", false)
   player.Character:SetAttribute("StartBlocking", nil)
   Remotes.Block:FireClient(player)
   Remotes.Effect:FireAllClients("BreakBlock", player.Character)
end

--//

function Bandit:Configure()
   Package.Configure(self)

   self._hitBoxStatus = "None"

   local Humanoid = self.Humanoid :: Humanoid
   Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

   Hair:Assert(self.Body, Hair:Sort())
   Mouth:Assert(self.Body, Mouth:Sort())
   Face:Assert(self.Body, Face:Sort())
   
   self.CombatAnimations = self:AnimationConvert(CombatAnimations)
   self.CombatLimit = #self.CombatAnimations -- Animations array length
   self.CombatAnimationRunning = 0 -- Animation who is playing
   self.CombatHitIndex = 0 -- Incresead when hit someone
   self.CanAttack = true -- if can attack
   self.ForceNonAttack = false
   self.LastHit = os.clock() -- mark the last hit 
   self.LastPlayerHit = tick() -- mark the last hitted by a player
   self.PlayersHits = {} :: {[any]: Player}
   self.AwaitingForRunThread = nil
   self.NpcHealth = Humanoid.Health

   local HitSignal = Instance.new("BindableEvent", self.Body)
   HitSignal.Name = 'HitSignal'
   
   local NpcStartPosition = self.Body.PrimaryPart.Position :: Vector3
   local NpcMoveClass = followPlayer(Humanoid)
   
   local PlayerTarget = State.new(nil)
   local PlayerAreaConfirmThread = nil

   task.defer(function()
      local Head = self.Body.Head
      local GuiName = Head:FindFirstChild("GuiName")
      if GuiName then GuiName:Destroy() end
      GuiName = ReplicatedStorage.Packages.GuiName:Clone()
      GuiName.Parent = Head

      local Slide: Frame = GuiName:FindFirstChild("Slide", true)
      Slide:TweenSize(UDim2.fromScale(Humanoid.Health/Humanoid.MaxHealth, 1))
      local healthChange; healthChange = Humanoid.HealthChanged:Connect(function()
         if not Humanoid then healthChange:Disconnect() end
         Slide:TweenSize(UDim2.fromScale(Humanoid.Health/Humanoid.MaxHealth, 1))
      end)
   end)

   HitSignal.Event:Connect(function(PlayerHitted: Player)
      if isDead(Humanoid) then
         HitSignal:Destroy()
         return
      end
      self:NonAttack(.9)
      if table.find(self.PlayersHits, PlayerHitted) then return end
      table.insert(self.PlayersHits, PlayerHitted)
   end)

   local healthChanged; healthChanged = Humanoid.HealthChanged:Connect(function(health)
      if health < self.NpcHealth then
         self.LastPlayerHit = tick()
      end

      self.NpcHealth = health
   end)

   task.spawn(function()
      while task.wait() do
         if isDead(Humanoid) then return end
         
         if (tick() - self.LastPlayerHit) < .5 then
            self.ForceNonAttack = true
            self.AwaitingForRunThread = task.delay(.5, function()
               if self.AwaitingForRunThread ~= coroutine.running() then return end
               self.ForceNonAttack = false
               self.AwaitingForRunThread = nil
            end)
         elseif not self.AwaitingForRunThread then
            self.ForceNonAttack = false
         end
      end
   end)

   local ObserveLastHit; ObserveLastHit = task.spawn(function()
      while task.wait() do
         if not self.LastHit then return task.cancel(ObserveLastHit) end
         if (os.clock() - self.LastHit) > .75 then
            self.CombatHitIndex = 0
         end
      end
   end)

   local PlayerObserveState = PlayerTarget:observe(function(player: Player)
      if not player then
         self.Body.HumanoidRootPart:SetNetworkOwner(nil)
         NpcMoveClass:follow(NpcStartPosition)
         return
      end

      local character = player.Character
      local playerHumanoid = character.Humanoid
      
      if isDead(playerHumanoid) then return end

      while task.wait() do
         if isDead(Humanoid) then return end
         if isDead(playerHumanoid)  then
            PlayerTarget:set(nil)
            return
         end
         local playerDistance = distance(character, self) :: number

         if playerDistance > 25 then
            PlayerTarget:set(nil)
            return
         end

         NpcMoveClass:follow(character.PrimaryPart.Position + (character.PrimaryPart.CFrame.LookVector * 2))
         
         if playerDistance <= 6 and self.CanAttack then
            if self.ForceNonAttack then continue end
            if (playerHumanoid:GetState() ~= Enum.HumanoidStateType.Running) then continue end

            self.Body.HumanoidRootPart:SetNetworkOwner(player)
            self:Attack()
            lookAt(self.Body, character.PrimaryPart.Position)
         end

         --warn("running to player position")
      end
   end)

   Humanoid.Died:Once(function()
      healthChanged:Disconnect()
      for _, Player in self.PlayersHits do
         local class = PlayerService.GetPlayerClass(Player)
         if class then
            class.PlayerKilledNpc:Fire("Bandit")
         end
         class._data.PlayerData:SetAttribute("Exp", class._data.PlayerData:GetAttribute("Exp") + (self.Class.KillAward or 15))
         class._data.PlayerData:SetAttribute("Cash", class._data.PlayerData:GetAttribute("Cash") + (self.Class.KillAward or 30))
      end
      self.HitBox:Destroy()
      PlayerObserveState:remove()
      if PlayerAreaConfirmThread then task.cancel(PlayerAreaConfirmThread) end
      if ObserveLastHit then task.cancel(ObserveLastHit) end
   end)


   PlayerAreaConfirmThread = task.spawn(function()
      while true do
         RunService.Heartbeat:Wait()
         if PlayerTarget.__value then continue end
         
         for _, Player in Players:GetPlayers() do
            if not Player.Character then continue end
            if isDead(Player.Character.Humanoid) then continue end
            
            if (Player.Character.PrimaryPart.Position - self.Body.PrimaryPart.Position).Magnitude < 14 then
               PlayerTarget:set(Player)
            end
         end
      end
   end)

   self:ConfigureHitBox()
   self:LoadAnimationsForScript()

   self.Humanoid:MoveTo(self.Body.HumanoidRootPart.CFrame.LookVector*0.15)
end

function Bandit:ConfigureHitBox()
   local Paramters = OverlapParams.new()
   Paramters.FilterDescendantsInstances = {workspace:WaitForChild("Npcs")}
   Paramters.MaxParts = 1

   self._hitBoxStatus = "Loaded"
   self.HitBox = Overlap.new({
      BasePart = self.Body.HumanoidRootPart,
      HitBoxSize = Vector3.new(4,4,6),
      Paramters = Paramters
   })

   self.HitBox.OnHit:Connect(function(Humanoid: Humanoid)
      if isDead(Humanoid) or self.ForceNonAttack or (Humanoid:GetState() ~= Enum.HumanoidStateType.Running) or (Humanoid.RootPart.Position - self.Body.PrimaryPart.Position).Magnitude > 7 then
         return
      end

      local _, Player = pcall(function()
         return Players:GetPlayerFromCharacter(Humanoid:FindFirstAncestorOfClass("Model"))
      end)

      if not Player then return end

      local PlayerCharacter = Humanoid.Parent
      if Humanoid.Parent:GetAttribute("Blocking") then
         PlayerCharacter:SetAttribute("AttacksInBlock", (PlayerCharacter:GetAttribute("AttacksInBlock") or 0 ) + 1)
         Remotes.Effect:FireAllClients("Block", Humanoid.Parent)

         if PlayerCharacter:GetAttribute("AttacksInBlock") >= (PlayerCharacter:GetAttribute("HitLimit") or 5) then
            local sucess = pcall(function()
               breakBlockPlayer(Player)
            end)
            
            warn("break block result: ", sucess)
            PlayerCharacter:SetAttribute("AttacksInBlock", 0)
            return
         end

         if PlayerCharacter:GetAttribute("StartBlocking") then
            local duration = math.abs(os.clock() - PlayerCharacter:GetAttribute("StartBlocking"))
            
            if duration <= .5 then
               Remotes.Effect:FireAllClients("PerfectBlock", PlayerCharacter)
               self:NonAttack(.8)
            else
               Remotes.Effect:FireAllClients("Block", PlayerCharacter)
            end
         end

         return
      end
      
      local Damage = self.Class.AttackDamage
      self.LastHit = os.clock()
      self.CombatHitIndex += 1

      if self.CombatHitIndex == self.CombatLimit then
         self.CombatHitIndex = 0
         warn("criticall")

         Damage *= 2
         Remotes.Effect:FireAllClients("Hit", Humanoid.Parent, true)
         Remotes.Effect:FireAllClients("NpcCritical", Humanoid.Parent)
         Remotes.Effect:FireAllClients("Landed", Humanoid.Parent, 1, .3)

         pcall(function()
            Remotes.Stun:FireClient(Players:GetPlayerFromCharacter(Humanoid:FindFirstAncestorOfClass("Model")))
         end)
         
         task.spawn(function()   
            self:NonAttack(2)
         end)
      end

      Humanoid:TakeDamage(Damage)
      Remotes.Effect:FireAllClients("Hit", Humanoid.Parent)
      Remotes.PlayerHited:FireClient(Player)
   end)
end

function Bandit:LoadAnimationsForScript()
   local Class = self.Class
   local Character = self.Body
   local Animate = Character:WaitForChild("Animate")
   
   Animate.walk.WalkAnim.AnimationId = Class.Animations.Walk
   Animate.idle.Animation1.AnimationId = Class.Animations.Idle
   Animate.run.RunAnim.AnimationId = Class.Animations.Run
end

function Bandit:AnimationConvert(target)
   local package = {}
   local list = target or self.Class.Animations
   local humanoid = self.Body.Humanoid
   local animator = humanoid:FindFirstChild("Animator") or humanoid

   for _, AnimationId in list do
      local Animation = Instance.new("Animation")
		Animation.AnimationId = AnimationId
		local track = animator:LoadAnimation(Animation)
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = false
		table.insert(package, track)
   end
   
   return package :: {[any]: AnimationTrack}
end

function Bandit:Attack()
   if self.ForceNonAttack then return end

   self.CanAttack = false
   self.CombatAnimationRunning = if self.CombatAnimationRunning >= self.CombatLimit then 1 else self.CombatAnimationRunning + 1 
   local Animation: AnimationTrack = self.CombatAnimations[self.CombatAnimationRunning]

   Animation:Play(.05)
   Animation.Looped = false

   self.HitBox:HitStart(Animation.Length-.1)
   task.wait(Animation.Length)
   Animation:Stop(.05)

   self.CanAttack = true
end

function Bandit:NonAttack(duration)
   if self.__forced then
      return
   end
   self.LastPlayerHit = tick()
   self.ForceNonAttack = true
   self.__forced = task.delay(duration, function()
      self.ForceNonAttack = false
   end)
end

local CanAttack: boolean = true
local AttackDelay: number = 3

local function fireBall(...: any?)
   warn(...)
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
   if gameProcessedEvent then return end --//player digitando ou focus em textbox

   if input.KeyCode == Enum.KeyCode.F then
      CanAttack = false
      fireBall()
      task.wait(AttackDelay)
      CanAttack = true
   end
end)

return Bandit