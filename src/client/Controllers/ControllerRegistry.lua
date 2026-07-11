local Registry={}
Registry.Controllers={}
function Registry:Register(name,controller) self.Controllers[name]=controller end
function Registry:Get(name) return self.Controllers[name] end
function Registry:Start()
 for _,controller in pairs(self.Controllers) do
  if controller.Start then controller:Start() end
 end
end
return Registry
