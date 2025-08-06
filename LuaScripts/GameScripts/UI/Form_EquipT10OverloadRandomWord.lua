local Form_EquipT10OverloadRandomWord = class("Form_EquipT10OverloadRandomWord", require("UI/UIFrames/Form_EquipT10OverloadRandomWordUI"))
local SHOW_ATTR_TIPS_NUM = 6
local MaxAttrItemNum = 3
local ATTR_MAX_LEVEL = 20

function Form_EquipT10OverloadRandomWord:SetInitParam(param)
end

function Form_EquipT10OverloadRandomWord:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetItemIcon = self:createCommonItem(self.m_common_item)
end

function Form_EquipT10OverloadRandomWord:OnActive()
  self.super.OnActive(self)
  self:DestroyItem()
  self:AddEventListeners()
  self.m_equipData = self.m_csui.m_param.equipData
  self.m_openType = self.m_csui.m_param.openType
  self.m_stItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_equipData.iBaseId,
    iNum = 0
  }, self.m_equipData)
  self.m_replaceBackFun = self.m_csui.m_param.replaceBackFun
  self:RefreshUI()
end

function Form_EquipT10OverloadRandomWord:RefreshUI()
  self.m_widgetItemIcon:SetItemInfo(self.m_stItemData)
  self.m_txt_equip_name_Text.text = self.m_stItemData.name
  self:RefreshOverLoadExAttr()
  local title = ""
  if self.m_openType == 1 then
    title = ConfigManager:GetCommonTextById(20103)
  elseif self.m_openType == 2 then
    title = ConfigManager:GetCommonTextById(20104)
  else
    title = ConfigManager:GetCommonTextById(20105)
  end
  self.m_txt_overload_successful_Text.text = title
end

function Form_EquipT10OverloadRandomWord:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:DestroyItem()
end

function Form_EquipT10OverloadRandomWord:AddEventListeners()
  self:addEventListener("eGameEvent_SaveReOverload", handler(self, self.OnEventSaveReOverload))
end

function Form_EquipT10OverloadRandomWord:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipT10OverloadRandomWord:CheckGetChangeEffectList()
  local changeEffectList = {}
  if not self.m_equipData then
    return changeEffectList
  end
  local tempChangeEffectMap = table.deepcopy(self.m_equipData.mChangingEffect)
  local overloadEffectMap = self.m_equipData.mOverloadEffect
  for i = 1, MaxAttrItemNum do
    local isHaveDataCurrent = overloadEffectMap[i] ~= nil
    local isHaveDataAfterChange = tempChangeEffectMap[i] ~= nil
    local isHaveChange = false
    if isHaveDataCurrent ~= isHaveDataAfterChange then
      isHaveChange = true
    elseif isHaveDataAfterChange then
      local tempCurEffectData = overloadEffectMap[i]
      local tempChangeEffectData = tempChangeEffectMap[i]
      if tempCurEffectData.iGroupId ~= tempChangeEffectData.iGroupId or tempCurEffectData.iEffectLevel ~= tempChangeEffectData.iEffectLevel then
        isHaveChange = true
      end
    end
    if isHaveChange then
      local changeData = {
        equipEffectData = tempChangeEffectMap[i]
      }
      changeEffectList[i] = changeData
    end
  end
  return changeEffectList
end

function Form_EquipT10OverloadRandomWord:RefreshOverLoadExAttr()
  local overloadEffect = table.deepcopy(self.m_equipData.mOverloadEffect)
  for i, v in pairs(self.m_equipData.mChangingEffect) do
    overloadEffect[3 + i] = v
  end
  for i = 1, SHOW_ATTR_TIPS_NUM do
    if overloadEffect[i] then
      local effectCfg = EquipManager:GetEquipEffectCfgByIdLv(overloadEffect[i].iGroupId, overloadEffect[i].iEffectLevel)
      local highQuality = effectCfg.m_HighQuality
      self["m_bg1_item" .. i]:SetActive(highQuality == 1)
      self["m_bg2_item" .. i]:SetActive(highQuality ~= 1)
      self["m_txt_level_item" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(20033), tostring(overloadEffect[i].iEffectLevel))
      local cfgList = EquipManager:GetEquipEffectCfgByGroupId(overloadEffect[i].iGroupId)
      if self.m_overLoadItemList[i] then
        for _, obj in pairs(self.m_overLoadItemList[i]) do
          UILuaHelper.SetActive(obj, false)
        end
      end
      for m = 1, cfgList.Count do
        self["m_item_red" .. i]:SetActive(false)
        if not self.m_overLoadItemList[i] then
          self.m_overLoadItemList[i] = {}
        end
        if not self.m_overLoadItemList[i][m] then
          local cloneObj = self:CreateOverLoadItem(self["m_item_red" .. i], self["m_img_list_schedule" .. i].transform)
          self.m_overLoadItemList[i][m] = cloneObj
        end
        local showRed = m <= overloadEffect[i].iEffectLevel
        self:ShowOverLoadAttrLevel(self.m_overLoadItemList[i][m], showRed)
      end
      self["m_txt_desc_item" .. i .. "_Text"].text = tostring(effectCfg.m_mDesc)
      self["m_txt_num_item" .. i .. "_Text"].text = tostring(effectCfg.m_Data)
      self["m_pnl_type1_item" .. i]:SetActive(true)
      self["m_pnl_type2_item" .. i]:SetActive(false)
    else
      self["m_pnl_type1_item" .. i]:SetActive(false)
      self["m_pnl_type2_item" .. i]:SetActive(true)
    end
  end
end

function Form_EquipT10OverloadRandomWord:CreateOverLoadItem(item_base_obj, parentTransform)
  local cloneObj = GameObject.Instantiate(item_base_obj, parentTransform).gameObject
  UILuaHelper.SetActive(cloneObj, true)
  return cloneObj
end

function Form_EquipT10OverloadRandomWord:ShowOverLoadAttrLevel(cloneObj, showRed)
  local rootTrans = cloneObj.transform
  local normalNode = rootTrans:Find("bg_red")
  local chooseNode = rootTrans:Find("bg_gray")
  normalNode.gameObject:SetActive(showRed)
  chooseNode.gameObject:SetActive(not showRed)
  UILuaHelper.SetActive(cloneObj, true)
end

function Form_EquipT10OverloadRandomWord:DestroyItem()
  if self.m_overLoadItemList and table.getn(self.m_overLoadItemList) > 0 then
    for i = SHOW_ATTR_TIPS_NUM, 1, -1 do
      for m = ATTR_MAX_LEVEL, 1, -1 do
        if self.m_overLoadItemList[i] and self.m_overLoadItemList[i][m] then
          CS.UnityEngine.GameObject.Destroy(self.m_overLoadItemList[i][m])
          self.m_overLoadItemList[i][m] = nil
        end
      end
    end
  end
  self.m_overLoadItemList = {}
end

function Form_EquipT10OverloadRandomWord:OnBtnchangeClicked()
  EquipManager:OnReqEquipSaveReOverload(self.m_equipData.iEquipUid, true)
end

function Form_EquipT10OverloadRandomWord:OnBtnsaveClicked()
  EquipManager:OnReqEquipSaveReOverload(self.m_equipData.iEquipUid, false)
end

function Form_EquipT10OverloadRandomWord:OnEventSaveReOverload(params)
  if not params then
    return
  end
  self:OnBtnCloseClicked()
  if self.m_replaceBackFun ~= nil then
    local changeEffectList = self:CheckGetChangeEffectList()
    self.m_replaceBackFun(params.bSave, self.m_equipData.iEquipUid, changeEffectList)
    self.m_replaceBackFun = nil
  end
end

function Form_EquipT10OverloadRandomWord:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_EquipT10OverloadRandomWord:IsOpenGuassianBlur()
  return true
end

function Form_EquipT10OverloadRandomWord:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipT10OverloadRandomWord", Form_EquipT10OverloadRandomWord)
return Form_EquipT10OverloadRandomWord
