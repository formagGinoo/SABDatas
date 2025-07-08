local co = coroutine

local function pong(func, callback)
  assert(type(func) == "function", "type error :: expected func")
  local thread = co.create(func)
  local step
  
  function step(...)
    local stat, ret = co.resume(thread, ...)
    assert(stat, ret)
    if co.status(thread) == "dead" then
      ;(callback or function()
      end)(ret)
    else
      assert(type(ret) == "function", "type error :: expected func")
      ret(step)
    end
  end
  
  step()
end

local function wrap(func)
  assert(type(func) == "function", "type error :: expected func")
  
  local function factory(...)
    local params = {
      ...
    }
    
    local function thunk(step)
      table.insert(params, step)
      return func(table.unpack(params))
    end
    
    return thunk
  end
  
  return factory
end

local function join(thunks)
  local len = table.getn(thunks)
  local done = 0
  local acc = {}
  
  local function thunk(step)
    if len == 0 then
      return step()
    end
    for i, tk in ipairs(thunks) do
      assert(type(tk) == "function", "thunk must be function")
      
      local function callback(...)
        acc[i] = {
          ...
        }
        done = done + 1
        if done == len then
          step(table.unpack(acc))
        end
      end
      
      tk(callback)
    end
  end
  
  return thunk
end

local function await(defer)
  assert(type(defer) == "function", "type error :: expected func")
  return co.yield(defer)
end

local function await_all(defer)
  assert(type(defer) == "table", "type error :: expected table")
  return co.yield(join(defer))
end

return {
  sync = wrap(pong),
  wait = await,
  wait_all = await_all,
  wrap = wrap
}
