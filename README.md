# Chain Lua

Chain Lua is a small easy to understand functional library implemented as a module that can wrap Lua tables.

Function invocations follow the fluent inteface, enabling method chaining for complex but human readable operations:


```lua
Chain = require 'Chain'

local t1 = Chain:with({ foo = "bar", one = "two", three = "four" })  

local output = 
  t1:merge({ five = "six" }):
  map(function(k, v) return k, v .. "mapped" end):
  reject_unless(function(k, v) return k == "foo" or v == "sixmapped" end)
 ```
 
 ## How To Chain
-  Create a new chain with an empty table with `Chain:new()`
-  Wrap an existing table using `Chain:with(...)`



When wrapping an existing table, the exisitng meta table is saved and used to lookup fields before `Chain`:

```lua
..
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
```

Unlinking resets the table to its original meta table:

```lua
function Chain:unlink()
  setmetatable(self, getmetatable(self).__original_meta_table)

  return self
end
```
 
 ## Mutation
 
 Functions that alter the internal table state have two flavours: functions with `inline` in the title mutate the table while those without implicitly return a new table instance:
 
 ```lua
 function Chain:merge_inline(t)
  assert_table(t)

  for k, v in pairs(t) do
    self[k] = v
  end

  return self
end

function Chain:merge(t) return Chain:new():merge_inline(self):merge_inline(t) end
```
