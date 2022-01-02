-- Chain Lua
-- Author: Tyler Matthews @matthewstyler
local Chain = {}

local function assert_function(fun)
  assert((type(fun) == "function"), "fun must be a function not " .. tostring(type(fun)))
end

local function assert_table(t, name)
  assert((type(t) == "table"), (name or "t") .. " must be a table not " .. tostring(type(t)))
end

function Chain:new() return Chain:with({}) end

function Chain:with(t)
  assert_table(t)

  local orig_meta_table = getmetatable(t)

  index = {
    __index = function(g, k)
      if orig_meta_table and orig_meta_table[k] then
        return orig_meta_table[k]
      elseif k == "is_a_chain" then
        return true
      else
        return self[k]
      end
    end,
    __original_meta_table = orig_meta_table,
  }
  setmetatable(t, index)

  return t
end

function Chain:copy() return self:merge({}) end

function Chain:for_each_with_index(fun)
  assert_function(fun)

  for key, value in pairs(self) do
    fun(key, value)
  end

  return self
end

function Chain:for_each(fun)
  assert_function(fun)

  for _, value in pairs(self) do
    fun(value)
  end

  return self
end

function Chain:for_each_key(fun)
  assert_function(fun)

  for key, _ in pairs(self) do
    fun(key)
  end

  return self
end

function Chain:merge_inline(t)
  assert_table(t)

  for k, v in pairs(t) do
    self[k] = v
  end

  return self
end

function Chain:merge(t)
  assert_table(t)

  return Chain:new():merge_inline(self):merge_inline(t)
end

function Chain:map_inline(fun)
  assert_function(fun)

  accumulator = {}
  self:for_each_with_index(
    function(key, value)
      local new_key, new_val = fun(key, value)
      accumulator[new_key] = new_val
      self[key] = nil
    end
  ):merge_inline(accumulator)

  return self
end

function Chain:map(fun) return self:copy():map_inline(fun) end

function Chain:invert_inline()
  self:map_inline(
    function(k, v)
      return v, k
    end
  )
  
  return self
end

function Chain:invert() return self:copy():invert_inline() end

function Chain:slice_inline(keys)
  assert_table(keys)
  
  local key_map = Chain:with(keys):map(function(key, value)
    return value, true -- key attribute -> true
  end)
  
  self:for_each_key(function(key)
    if not key_map[key] then self[key] = nil end
  end)

  return self
end

function Chain:slice(keys) return self:copy():slice_inline(keys) end

function Chain:where(fun)
  assert_function(fun)

  local where_table = Chain:new()
  self:for_each_with_index(
    function(k, v)
      if fun(k, v) then
        where_table[k] = v
      end
    end
  )

  return where_table
end

function Chain:reject_inline_unless(fun)
  assert_function(fun)

  self:for_each_with_index(
    function(k, v)
      if not fun(k, v) then
        self[k] = nil
      end
    end
  )

  return self
end

function Chain:reject_unless(fun) return self:copy():reject_inline_unless(fun) end

function Chain:unlink()
  setmetatable(self, getmetatable(self).__original_meta_table)

  return self
end

return Chain
