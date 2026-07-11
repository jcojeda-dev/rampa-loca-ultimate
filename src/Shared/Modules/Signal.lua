export type Connection={Disconnect:(Connection)->()}
local Signal={}
Signal.__index=Signal
function Signal.new()
 local self=setmetatable({},Signal)
 self._connections={}
 return self
end
function Signal:Connect(callback)
 table.insert(self._connections,callback)
 local connection={}
 function connection:Disconnect()
  for i,v in ipairs(self._connections) do
   if v==callback then table.remove(self._connections,i) break end
  end
 end
 return connection
end
function Signal:Fire(...)
 for _,cb in ipairs(self._connections) do
  task.spawn(cb,...)
 end
end
return Signal
