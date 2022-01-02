package.path = package.path .. ';./?.lua;'

Chain = require 'Chain'

local function passed() print("...") end

local function test_chain_definition()
  local unchained_table = {}
  local original_meta_table = getmetatable(unchained_table)

  local chained_table = Chain:with(unchained_table)
  local chain_table_meta_table = getmetatable(chained_table)

  assert(original_meta_table ~= chain_table_meta_table, "Chain is defined by a new metatable")
  assert(chained_table["is_a_chain"] == true)
  
  passed()
end

local function test_chain_initialization()
  local invalid_initalizers = { "", 1,  false, function() end, nil }
  
  Chain:with(invalid_initalizers):for_each(function(val)
    local intialized, err = pcall(function() Chain:with(val) end) 
    if intialized then
      error("Chain should not be able to become initalized with " .. tostring(val))
    end
  end)

  passed()
end

local function test_for_each_with_index()
  local chain = Chain:with({ 2, 3, 4 })
  local index = 1
  
  chain:for_each_with_index(function(key, value)
    assert(key == index, "expected " .. tostring(index) .. " not " .. tostring(key))
    assert(value == index + 1, "expected " .. tostring(index + 1) .. " not " .. tostring(value))
    
    index = index + 1
  end)    

  passed()
end

local function test_for_each()
    -- Array Case
  local chain = Chain:with({ 2, 3, 4 })
  local val = 1
  
  chain:for_each(function(value)
    assert(value == val + 1, "expected " .. tostring(val + 1) .. " not " .. tostring(value))
    
    val = val + 1
  end)    

  -- Map case
  chain = Chain:with({ foo = "bar", [123] = 456 })
  val = { bar = true, [456] = true }
  
  chain:for_each(function(value)
    assert(val[value] ~= nil, tostring(value) .. " was not an expected value")
  end)

  passed()
end

local function test_for_each_key()
  -- Array Case
  local chain = Chain:with({ 2, 3, 4 })
  local val = 1
  
  chain:for_each_key(function(key)
    assert(key == val, "expected " .. tostring(val) .. " not " .. tostring(key))
    
    val = val + 1
  end)    

  -- Map case
  chain = Chain:with({ foo = "bar", [123] = 456 })
  val = { foo = true, [123] = true }
  
  chain:for_each_key(function(key)
    assert(val[key] ~= nil, tostring(key) .. " was not an expected key")
  end)

  passed()
end

local function test_merge_inline()
  local t1 = Chain:with({
    foo = "bar",
    test = "123"
  })
  local t2 = {
    new = "value",
    lookup = "table",
    foo = "overwritten"
  }
  local t3 = { 1, 2, 3 }
  
  local expected_values = Chain:with({
    [1]=1,
    [2]=2,
    [3]=3,
    new = "value",
    lookup = "table",
    foo = "overwritten",
    test = "123"
  })
  
  t1:merge_inline(t2):merge_inline(t3)
  
  expected_values:for_each_with_index(function(key, value)
    assert(t1[key] == value, "expected " .. tostring(value) .. " for key " .. tostring(key) .. " not " .. tostring(t1[key]))
  end)

  assert(t1 ~= t2)
  assert(t1 ~= t3)
  
  passed()
end

local function test_merge()
  local t1 = Chain:with({
    foo = "bar",
    test = "123"
  })
  local t2 = {
    new = "value",
    lookup = "table",
    foo = "overwritten"
  }
  local t3 = { 1, 2, 3 }
  
  local expected_values = Chain:with({
    [1] = 1,
    [2] = 2,
    [3] = 3,
    new = "value",
    lookup = "table",
    foo = "overwritten",
    test = "123"
  })
  
  local merged_table = t1:merge(t2):merge(t3)
  
  expected_values:for_each_with_index(function(key, value)
    assert(merged_table[key] == value, "expected " .. tostring(value) .. " for key " .. tostring(key) .. " not " .. tostring(merged_table[key]))
  end)

  assert(t1 ~= merged_table)
  assert(t2 ~= merged_table)
  assert(t3 ~= merged_table)
  assert(t1[1] == nil)
  assert(merged_table[1] ~= nil)
  
  passed()
end

local function test_map_inline()
  
  -- Changing Value of Array
  local t1 = Chain:with({ 2, 3, 4 })
  
  t1:map_inline(function(key, val)
    return key, val .. "mapped"
  end) 

  local expected_values = Chain:with({
    "2mapped",
    "3mapped",
    "4mapped"
  })

  expected_values:for_each_with_index(function(index, val)
    assert(t1[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(t1[index]))
  end)

  -- Changing Value of Map
  t1 = Chain:with({
    foo = "bar",
    test = "123"
  })
  
  t1:map_inline(function(key, val)
    return key, val .. "mapped"
  end) 

  expected_values = Chain:with({
    foo = "barmapped",
    test ="123mapped"
  })

  expected_values:for_each_with_index(function(index, val)
    assert(t1[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(t1[index]))
  end)

  -- Changing Key/Value of Array
  t1 = Chain:with({ 2, 3, 4 })
  
  t1:map_inline(function(key, val)
    return val, val .. "mapped"
  end) 

  expected_values = Chain:with({
    [2]="2mapped",
    [3]="3mapped",
    [4]="4mapped"
  })

  expected_values:for_each_with_index(function(index, val)
    assert(t1[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(t1[index]))
  end)
  
  passed()
end

function test_map()
  -- Changing Value of Array
  local t1 = Chain:with({ 2, 3, 4 })
  
  local new_table = t1:map(function(key, val)
    return key, val .. "mapped"
  end) 

  local expected_values = Chain:with({
    "2mapped",
    "3mapped",
    "4mapped"
  })

  expected_values:for_each_with_index(function(index, val)
    assert(new_table[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(new_table[index]))
  end)
  assert(new_table ~= t1)

  -- Changing Value of Map
  t1 = Chain:with({
    foo = "bar",
    test = "123"
  })
  
  new_table = t1:map(function(key, val)
    return key, val .. "mapped"
  end) 

  expected_values = Chain:with({
    foo = "barmapped",
    test ="123mapped"
  })

  expected_values:for_each_with_index(function(index, val)
    assert(new_table[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(new_table[index]))
  end)
  assert(new_table ~= t1)

  -- Changing Key/Value of Array
  t1 = Chain:with({ 2, 3, 4 })
  
  new_table = t1:map(function(key, val)
    return val, val .. "mapped"
  end) 

  expected_values = Chain:with({
    [2]="2mapped",
    [3]="3mapped",
    [4]="4mapped"
  })

  expected_values:for_each_with_index(function(index, val)
    assert(new_table[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(new_table[index]))
  end)
  assert(new_table ~= t1)
  
  passed()
end

function test_invert_inline()
  local t1 = Chain:with({ 2, 3, 4 })
  
  t1:invert_inline()
  
  local expected_values = Chain:with({
    [2] = 1,
    [3] = 2,
    [4] = 3
  })  

  expected_values:for_each_with_index(function(index, val)
    assert(t1[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(t1[index]))
  end)

  passed()
end

function test_invert()
  local t1 = Chain:with({ 2, 3, 4 })
  
  local t2 = t1:invert()
  
  local expected_values = Chain:with({
    [2] = 1,
    [3] = 2,
    [4] = 3
  })  

  expected_values:for_each_with_index(function(index, val)
    assert(t2[index] == val, "expected " .. tostring(val) .. " for key " .. tostring(index) .. " not " .. tostring(t2[index]))
  end)
  assert(t1 ~= t2)

  passed()
end

function test_slice_inline()
  local t1 = Chain:with({
    val = "one",
    val_two = "two",
    val_three = "three"
  })
  
  t1:slice_inline({ "val", "val_three" })

  assert(t1["val"] == "one", "expected one not " .. tostring(t1["val"]))
  assert(t1["val_three"] == "three")
  assert(t1["val_two"] == nil)
  
  passed()
end

function test_slice()
  local t1 = Chain:with({
    val = "one",
    val_two = "two",
    val_three = "three"
  })
  
  local t2 = t1:slice({ "val", "val_three" })

  assert(t2["val"] == "one", "expected one not " .. tostring(t1["val"]))
  assert(t2["val_three"] == "three")
  assert(t2["val_two"] == nil)
  
  assert(t1 ~= t2)
  
  passed()
end

function test_where()
  local t1 = Chain:with({ foo = "bar", t_where = "table" })
  
  local where_table = t1:where(function(k, v)
    return k == "t_where"
  end)
  
  assert(where_table["t_where"] == "table")
  assert(where_table["foo"] == nil)
  assert(where_table ~= t1)
  passed()
end

function test_reject_inline_unless()
  local t1 = Chain:with({ foo="bar", test="one", test_two="two", test_three="three" })
  
  t1:reject_inline_unless(function(k, v)
    return k == "test_two" or v == "three"
  end)
  
  assert(t1["test_two"] == "two")
  assert(t1["test_three"] == "three")
  assert(t1["foo"] == nil)
  assert(t1["test"] == nil)
  passed()
end

function test_reject_unless()
  local t1 = Chain:with({ foo="bar", test="one", test_two="two", test_three="three" })
  
  local t2 = t1:reject_unless(function(k, v)
    return k == "test_two" or v == "three"
  end)
  
  assert(t2["test_two"] == "two")
  assert(t2["test_three"] == "three")
  assert(t2["foo"] == nil)
  assert(t2["test"] == nil)
  assert(t2 ~= t1)
  assert(t1["foo"])
  assert(t1["test"])
  passed()
end

function test_unlink()
  local t1 = Chain:with({ foo = "bar" })
  
  assert(t1["with"]) -- asserting existence of object function
  assert(t1["is_a_chain"] == true) -- asserting identity index
  assert(t1["foo"] == "bar")
  
  t1:unlink()
  
  assert(t1["with"] == nil)
  assert(t1["is_a_chain"] == nil)
  assert(t1["foo"] == "bar")
  
  passed()
end

function test_chain_new()
  local t1 = Chain:new()
  
  assert(t1["is_a_chain"] == true) 
  
  passed()
end

function test_copy()
  local t1 = Chain:with({
    foo = "bar",
    test = "123"
  })
  
  local expected_values = Chain:with({
    foo = "bar",
    test = "123"
  })
  
  local copied_table = t1:copy()
  
  expected_values:for_each_with_index(function(key, value)
    assert(copied_table[key] == value, "expected " .. tostring(value) .. " for key " .. tostring(key) .. " not " .. tostring(copied_table[key]))
  end)

  assert(copied_table["is_a_chain"] == true)
  assert(copied_table ~= t1)
  
  passed()
end

function test_complex_chain()
  local t1 = Chain:with({ foo = "bar", one = "two", three = "four" })  

  local output = 
    t1:merge({ five = "six" }):
    map(function(k, v) return k, v .. "mapped" end):
    reject_unless(function(k, v) return k == "foo" or v == "sixmapped" end)
  
  assert(output["foo"] == "barmapped")
  assert(output["five"] == "sixmapped")
  assert(output["one"] == nil)
  assert(output["three"] == nil)
  
  assert(putput ~= t1)
  
  assert(t1["foo"] == "bar")
  assert(t1["five"] == nil)
  assert(t1["one"] == "two")
  assert(t1["three"] == "four")

end

test_chain_definition()
test_chain_initialization()
test_for_each_with_index()
test_for_each()
test_for_each_key()
test_merge_inline()
test_merge()
test_map_inline()
test_map()
test_invert_inline()
test_invert()
test_slice_inline()
test_slice()
test_where()
test_reject_inline_unless()
test_reject_unless()
test_unlink()
test_chain_new()
test_copy()
test_complex_chain()

print("All tests passed")
