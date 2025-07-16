local Form_EquipT10Overload = class("Form_EquipT10Overload", require("UI/UIFrames/Form_EquipT10OverloadUI"))
local OVER_LOAD_COST = ConfigManager:GetGlobalSettingsByKey("OverloadCost")

function Form_EquipT10Overload:SetInitParam(param)
end

function Form_EquipT10Overload:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetItemIcon = self:createCommonItem(self.m_common_item)
end

function Form_EquipT10Overload:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_equipData = self.m_csui.m_param
  self.m_canOverLoad = true
  self:RefreshUI()
end

function Form_EquipT10Overload:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_EquipT10Overload:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipT10Overload:AddEventListeners()
  self:addEventListener("eGameEvent_Equip_Overload", handler(self, self.OnEquipOverLoadCB))
end

function Form_EquipT10Overload:RefreshUI()
  self:RefreshEquipAttrs()
end

function Form_EquipT10Overload:RefreshEquipAttrs()
  local flag = EquipManager:CheckIsShowCampAttAddExt(self.m_equipData.iEquipUid)
  local attrInfoList = EquipManager:GetEquipBaseAttr(self.m_equipData.iBaseId, self.m_equipData.iLevel, flag)
  local overLoadAttrInfoList = EquipManager:GetEquipOverLoadBaseAttr(self.m_equipData.iBaseId, 0)
  for i = 1, 2 do
    local attrInfo = attrInfoList[i]
    local overLoadInfo = overLoadAttrInfoList[i]
    if attrInfo and attrInfo.cfg and overLoadInfo and overLoadInfo.cfg then
      ResourceUtil:CreatePropertyImg(self["m_ability_icon" .. i .. "_Image"], attrInfo.id)
      local attrCfg = attrInfo.cfg
      self["m_txt_ability_name" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
      self["m_before_ability_num" .. i .. "_Text"].text = tostring(attrInfo.num)
      self["m_after_ability_num" .. i .. "_Text"].text = tostring(overLoadInfo.num)
    end
  end
  local itemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_equipData.iBaseId,
    iNum = 0
  }, self.m_equipData)
  self.m_widgetItemIcon:SetItemInfo(itemData)
  self.m_txt_equip_name_Text.text = itemData.name
  local costData = utils.changeStringRewardToLuaTable(OVER_LOAD_COST)
  local itemId = costData[1][1]
  local itemNum = costData[1][2]
  ResourceUtil:CreateItemIcon(self.m_consume_icon_Image, itemId)
  local userItemNum = ItemManager:GetItemNum(itemId, true)
  if itemNum <= userItemNum then
    self.m_canOverLoad = true
    UILuaHelper.SetColor(self.m_consume_quantity_Text, table.unpack(GlobalConfig.COMMON_COLOR.Normal2))
  else
    self.m_canOverLoad = false
    UILuaHelper.SetColor(self.m_consume_quantity_Text, table.unpack(GlobalConfig.COMMON_COLOR.Red))
  end
  self.m_consume_quantity_Text.text = userItemNum .. "/" .. itemNum
end

function Form_EquipT10Overload:OnEquipOverLoadCB(iEquipUid)
  self:OnCommonbtnblackClicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPT10OVERLOADSUCCESSFUL, iEquipUid)
end

function Form_EquipT10Overload:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_EquipT10Overload:IsOpenGuassianBlur()
  return true
end

function Form_EquipT10Overload:OnBtnconsumeClicked()
  if self.m_canOverLoad then
    EquipManager:OnReqEquipOverload(self.m_equipData.iEquipUid)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
  end
end

function Form_EquipT10Overload:OnCommonbtnblackClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_EquipT10Overload", Form_EquipT10Overload)
return Form_EquipT10Overload
