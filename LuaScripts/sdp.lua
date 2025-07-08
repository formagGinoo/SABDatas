local print = log.debug
local setmetatable = _ENV.setmetatable
local ipairs = _ENV.ipairs
local rawget = _ENV.rawget
local rawset = _ENV.rawset
local type = _ENV.type
local tostring = _ENV.tostring
local tonumber = _ENV.tonumber
local string = _ENV.string
local error = _ENV.error
local sdplua = require("sdplua")
sdp = {}
sdp.SdpType_Void = 0
sdp.SdpType_Bool = 1
sdp.SdpType_Char = 2
sdp.SdpType_Int8 = 3
sdp.SdpType_UInt8 = 4
sdp.SdpType_Int16 = 5
sdp.SdpType_UInt16 = 6
sdp.SdpType_Int32 = 7
sdp.SdpType_UInt32 = 8
sdp.SdpType_Int64 = 9
sdp.SdpType_UInt64 = 10
sdp.SdpType_Float = 11
sdp.SdpType_Double = 12
sdp.SdpType_String = 13
sdp.SdpType_Vector = 14
sdp.SdpType_Map = 15
sdp.SdpType_Enum = 16
sdp.SdpType_Struct = 17
sdp.typedesc_index = {}
sdp.SdpTypeInstanceMeta = {}

function sdp.createFromTypeDesc(typedesc, default)
  if type(typedesc) == "table" then
    if typedesc.TypeId == sdp.SdpType_Vector then
      local o = {}
      return o
    elseif typedesc.TypeId == sdp.SdpType_Map then
      local o = {}
      return o
    elseif typedesc.TypeId == sdp.SdpType_Struct then
      local o = {}
      o[sdp.typedesc_index] = typedesc
      for i = 1, #typedesc.Definition do
        local k = typedesc.Definition[i]
        local define = typedesc.Definition[k]
        local v = sdp.createFromTypeDesc(define[3], define[4])
        o[k] = v
      end
      if ProtoClient and typedesc.StructName and ProtoClient[typedesc.StructName] then
        setmetatable(o, {
          __index = ProtoClient[typedesc.StructName]
        })
        if o.Ctor ~= nil then
          o:Ctor()
        end
      end
      return o
    end
  else
    return default
  end
end

function sdp.SdpTypeInstanceMeta:__call()
  return sdp.createFromTypeDesc(self)
end

sdp.SdpStruct = {}
sdp.SdpStructTypeMeta = {}
setmetatable(sdp.SdpStruct, sdp.SdpStructTypeMeta)

function sdp.SdpStructTypeMeta:__call(name)
  local o = {}
  o.TypeId = sdp.SdpType_Struct
  o.StructName = name
  
  function o.new()
    return sdp.createFromTypeDesc(o)
  end
  
  function o.pack(obj)
    return sdp.pack(obj)
  end
  
  function o.unpack(data)
    return sdp.unpack(data, o)
  end
  
  function o.unpackPatch(data, obj)
    return sdp.unpackPatch(data, obj, o)
  end
  
  setmetatable(o, sdp.SdpTypeInstanceMeta)
  return o
end

sdp.SdpVector = {}
sdp.SdpVectorTypeMeta = {}
setmetatable(sdp.SdpVector, sdp.SdpVectorTypeMeta)
sdp.SdpVectorTypesKnown = {}

function sdp.SdpVectorTypeMeta:__call(innertype)
  if innertype == nil then
    return
  end
  local o = sdp.SdpVectorTypesKnown[innertype]
  if o == nil then
    o = {}
    o.TypeId = sdp.SdpType_Vector
    o.InnerType = innertype
    setmetatable(o, sdp.SdpTypeInstanceMeta)
    sdp.SdpVectorTypesKnown[innertype] = o
  end
  return o
end

sdp.SdpMap = {}
sdp.SdpMapTypeMeta = {}
setmetatable(sdp.SdpMap, sdp.SdpMapTypeMeta)
sdp.SdpMapTypesKnown = {}

function sdp.SdpMapTypeMeta:__call(keytype, valtype)
  if valtype == nil then
    return
  end
  local vtypes = sdp.SdpMapTypesKnown[keytype]
  local o
  if vtypes ~= nil then
    o = vtypes[valtype]
  end
  if o == nil then
    o = {}
    o.TypeId = sdp.SdpType_Map
    o.KeyType = keytype
    o.ValType = valtype
    setmetatable(o, sdp.SdpTypeInstanceMeta)
    if vtypes == nil then
      vtypes = {}
      sdp.SdpMapTypesKnown[keytype] = vtypes
    end
    vtypes[valtype] = o
  end
  return o
end

function sdp.display(o)
  local typedesc = o[sdp.typedesc_index]
  if typedesc == nil then
    error("not a sdp struct", 2)
    log.error("sdp.display not a sdp struct")
  end
  return sdplua.display(o, typedesc)
end

function sdp.pack(o)
  local typedesc = o[sdp.typedesc_index]
  if typedesc == nil then
    error("not a sdp struct", 2)
    log.error("sdp.pack not a sdp struct")
  end
  return sdplua.pack(o, typedesc)
end

function sdp.unpack(data, typedesc)
  if typedesc == nil then
    error("not a sdp struct", 2)
    log.error("sdp.unpack not a sdp struct")
  end
  local o = typedesc()
  if data == "" or data == nil then
    return o
  end
  return sdplua.unpack(data, o, typedesc)
end

function sdp.unpackPatch(data, o, typedesc)
  if typedesc == nil then
    error("not a sdp struct", 2)
  end
  return sdplua.unpackPatch(data, o, typedesc)
end

function sdp.gettype(o)
  return o[sdp.typedesc_index]
end

return sdp
