local HeroPlacePreStr = "hero_place_"
local HeroSpineType = UIMultiPoolType.HeroSpine
local HeroSpineDynamicLoader = class("HeroSpineDynamicLoader")

function HeroSpineDynamicLoader:ctor()
end

function HeroSpineDynamicLoader:CheckAllLoadAndBack(heroSpineLoadObj, backFun)
  if not heroSpineLoadObj then
    return
  end
  if not backFun then
    return
  end
  if not utils.isNull(heroSpineLoadObj.spinePlaceObj) and not utils.isNull(heroSpineLoadObj.spineObj) and backFun then
    backFun(heroSpineLoadObj)
  end
end

function HeroSpineDynamicLoader:CheckFreshPlaceSpineObj(heroSpineLoadObj)
  if not heroSpineLoadObj then
    return
  end
  if utils.isNull(heroSpineLoadObj.spinePlaceObj) then
    return
  end
  local spinePlaceTrans = heroSpineLoadObj.spinePlaceTrans
  local placeChildNum = spinePlaceTrans.childCount
  if placeChildNum == 0 then
    return
  end
  for i = 1, placeChildNum do
    local index = i - 1
    local tempPlaceTrans = spinePlaceTrans:GetChild(index)
    if not utils.isNull(tempPlaceTrans) then
      local tempSpineChildNum = tempPlaceTrans.childCount
      if 0 < tempSpineChildNum then
        for j = 1, tempSpineChildNum do
          local spineChildIndex = j - 1
          local tempSpineTrans = tempPlaceTrans:GetChild(spineChildIndex)
          if not utils.isNull(tempSpineTrans) then
            local tempSpineCom = tempSpineTrans:GetComponent("SkeletonGraphic")
            if tempSpineCom then
              GameObject.Destroy(tempSpineTrans.gameObject)
              heroSpineLoadObj.spineObj = nil
              heroSpineLoadObj.spineTrans = nil
              return
            end
          end
        end
      end
    end
  end
end

function HeroSpineDynamicLoader:GetSpineObjectByName(spineStr, loadBack)
  if not spineStr then
    return
  end
  if not loadBack then
    return
  end
  local assetSpineStr = spineStr
  if ActivityManager:IsInCensorOpen() == true then
    local tempSpineStr = ConfigManager:GetVerifyPathBySourceStr(spineStr)
    if tempSpineStr and tempSpineStr ~= "" then
      assetSpineStr = tempSpineStr
    end
  end
  local heroSpineLoadObj = {
    spineStr = spineStr,
    assetSpineStr = assetSpineStr,
    spineObj = nil,
    spineTrans = nil,
    spinePlaceObj = nil,
    spinePlaceTrans = nil
  }
  local heroPlacePrefabStr = HeroPlacePreStr .. assetSpineStr
  print("FIXBUG: GetObjectByType----", HeroSpineType, "-----" .. heroPlacePrefabStr)
  UIMultiTypeObjectPoolManager:GetObjectByType(HeroSpineType, heroPlacePrefabStr, function(backStr, placeObj)
    if UILuaHelper.IsNull(placeObj) then
      return
    end
    if backStr == heroPlacePrefabStr then
      heroSpineLoadObj.spinePlaceObj = placeObj
      heroSpineLoadObj.spinePlaceTrans = placeObj.transform
      self:CheckFreshPlaceSpineObj(heroSpineLoadObj)
      UIMultiTypeObjectPoolManager:GetObjectByType(HeroSpineType, assetSpineStr, function(spineBackStr, spineObj)
        if UILuaHelper.IsNull(spineObj) then
          return
        end
        if spineBackStr == assetSpineStr then
          heroSpineLoadObj.spineObj = spineObj
          heroSpineLoadObj.spineTrans = spineObj.transform
          self:CheckAllLoadAndBack(heroSpineLoadObj, loadBack)
        end
      end)
    end
  end)
end

function HeroSpineDynamicLoader:SetSpineInPos(spineLoaderObj, showTypeStr, uiParent, isNoPlayIdleAnim)
  if not spineLoaderObj then
    return
  end
  local heroSpine = spineLoaderObj.spineObj
  local heroPlace = spineLoaderObj.spinePlaceObj
  local heroPlaceTrans = spineLoaderObj.spinePlaceTrans
  if not heroPlace or UILuaHelper.IsNull(heroPlace) then
    return
  end
  if not heroSpine or UILuaHelper.IsNull(heroSpine) then
    return
  end
  local spineRoot = heroPlaceTrans:Find(showTypeStr)
  if spineRoot then
    UILuaHelper.SetActiveChildren(heroPlace, false)
    if spineRoot then
      UILuaHelper.SetParent(heroSpine, spineRoot, true)
      UILuaHelper.SetActive(spineRoot, true)
    end
  end
  if isNoPlayIdleAnim ~= true then
    UILuaHelper.SpinePlayAnim(heroSpine, 0, "idle", true)
  end
  if uiParent then
    UILuaHelper.SetParent(heroPlace, uiParent, true)
  end
end

function HeroSpineDynamicLoader:GetObjectByName(spineSomePrefabStr, loadBack)
  if not spineSomePrefabStr then
    return
  end
  if not loadBack then
    return
  end
  if ActivityManager:IsInCensorOpen() == true then
    local tempSpineStr = ConfigManager:GetVerifyPathBySourceStr(spineSomePrefabStr)
    if tempSpineStr and tempSpineStr ~= "" then
      spineSomePrefabStr = tempSpineStr
    end
  end
  UIMultiTypeObjectPoolManager:GetObjectByType(HeroSpineType, spineSomePrefabStr, function(backStr, spineSomethingObj)
    if UILuaHelper.IsNull(spineSomethingObj) then
      return
    end
    if backStr == spineSomePrefabStr and loadBack then
      loadBack(backStr, spineSomethingObj)
    end
  end)
end

function HeroSpineDynamicLoader:RecycleObjectByName(prefabStr, obj)
  if not prefabStr then
    return
  end
  if not obj then
    return
  end
  UIMultiTypeObjectPoolManager:RecycleObjectByType(HeroSpineType, prefabStr, obj)
end

function HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, loadSucBack)
  if not heroSpineAssetName then
    return
  end
  if not showTypeStr then
    return
  end
  self:GetSpineObjectByName(heroSpineAssetName, function(heroSpineLoadObj)
    if not heroSpineLoadObj then
      return
    end
    self:SetSpineInPos(heroSpineLoadObj, showTypeStr, uiParent)
    if loadSucBack then
      loadSucBack(heroSpineLoadObj)
    end
  end)
end

function HeroSpineDynamicLoader:RecycleHeroSpineObject(heroSpineLoadObj)
  if not heroSpineLoadObj then
    return
  end
  local heroSpine = heroSpineLoadObj.spineObj
  local heroPlace = heroSpineLoadObj.spinePlaceObj
  if not heroPlace or UILuaHelper.IsNull(heroPlace) then
    return
  end
  if not heroSpine or UILuaHelper.IsNull(heroSpine) then
    return
  end
  local heroSpineStr = heroSpineLoadObj.assetSpineStr
  if not heroSpineStr then
    return
  end
  UILuaHelper.SpineClearAnimPlayBack(heroSpine)
  self:RecycleObjectByName(heroSpineStr, heroSpine)
  local heroPlacePrefabStr = HeroPlacePreStr .. heroSpineStr
  self:RecycleObjectByName(heroPlacePrefabStr, heroPlace)
end

return HeroSpineDynamicLoader
