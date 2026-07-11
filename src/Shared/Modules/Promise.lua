local Promise={}
Promise.__index=Promise
function Promise.new(executor)
 local self=setmetatable({},Promise)
 task.spawn(function()
  executor(function(v) self._resolved=v end,function(r) self._rejected=r end)
 end)
 return self
end
function Promise:Await()
 repeat task.wait() until self._resolved or self._rejected
 if self._rejected then error(self._rejected) end
 return self._resolved
end
return Promise
