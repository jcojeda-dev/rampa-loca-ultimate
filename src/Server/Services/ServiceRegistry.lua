local Registry={}
Registry.Services={}
function Registry:Register(name,service) self.Services[name]=service end
function Registry:Get(name) return self.Services[name] end
function Registry:Start()
 for _,service in pairs(self.Services) do
  if service.Start then service:Start() end
 end
end
return Registry
