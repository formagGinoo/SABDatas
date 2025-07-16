local Form_EquipmentTips = class("Form_EquipmentTips", require("UI/UIFrames/Form_EquipmentTipsUI"))
local EquipmentConfigInstance = ConfigManager:GetConfigInsByName("Equipment")
local CampCfgIns = ConfigManager:GetConfigInsByName("CharacterCamp")

function Form_EquipmentTips:SetInitParam(param)
end

function Form_EquipmentTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_EquipmentTips:OnActive()
  self.tParam = self.m_csui.m_param.equipData
  self.m_selPos = self.m_csui.m_param.pos
  self.m_iBaseId = self.tParam.iBaseId
  self.m_iEquipLv = self.tParam.iLevel or 0
  self.m_stItemData = EquipmentConfigInstance:GetValue_ByEquipID(self.m_iBaseId)
  ResourceUtil:CreateEquipIcon(self.m_img_icon_ev_Image, self.m_iBaseId)
  if self.tParam.iHeroId and self.m_selPos and self.tParam.iHeroId ~= 0 and self.m_selPos ~= 0 then
    self.m_equip_btn:SetActive(true)
    self.m_btn_change:SetActive(true)
    self.m_btn_upgrade:SetActive(true)
  else
    self.m_equip_btn:SetActive(false)
    self.m_btn_change:SetActive(false)
    self.m_btn_upgrade:SetActive(false)
  end
  self.m_txt_name_Text.text = self.m_stItemData.m_mEquipName
  self.m_txt_num_Text.text = self.m_iEquipLv
  self:RefreshDesc()
  self:RefreshTips()
  self:RefreshAttrs()
  self:RefreshEquipCampInfo()
  self:AddEventListeners()
end

function Form_EquipmentTips:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_EquipmentTips:AddEventListeners()
  self:addEventListener("eGameEvent_Equip_UnInstallEquip", handler(self, self.OnEventUnInstallEquip))
end

function Form_EquipmentTips:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_EquipmentTips:RefreshDesc()
  self.m_pnl_des:SetActive(true)
  local v2TextDescOffset = self.m_txt_desc:GetComponent("RectTransform").anchoredPosition
  v2TextDescOffset.y = 0
  self.m_txt_desc:GetComponent("RectTransform").anchoredPosition = v2TextDescOffset
  self.m_txt_desc_Text.text = self.m_stItemData.m_mEquipDesc
end

function Form_EquipmentTips:RefreshTips()
  local qualityCfg = GlobalConfig.QUALITY_EQUIP_SETTING[self.m_stItemData.m_Quality]
  if qualityCfg then
    self.m_txt_quality_num_Text.text = ConfigManager:GetCommonTextById(qualityCfg.name)
  end
  ResourceUtil:CreateEquipPosImg(self.m_img_pos_Image, self.m_stItemData.m_PosRes)
  ResourceUtil:CreateEquipQualityImg(self.m_img_line_colour_Image, self.m_stItemData.m_Quality, GlobalConfig.EQUIP_QUALITY_STYLE.Line)
  ResourceUtil:CreateEquipQualityImg(self.m_img_quality_bg_Image, self.m_stItemData.m_Quality, GlobalConfig.EQUIP_QUALITY_STYLE.Default)
  ResourceUtil:CreateEquipTypeImg(self.m_img_equipType_Image, self.m_stItemData.m_EquiptypeRes)
end

function Form_EquipmentTips:RefreshAttrs()
  local flag = EquipManager:CheckIsShowCampAttAddExt(self.tParam.iEquipUid)
  local attrInfoList = EquipManager:GetEquipBaseAttr(self.m_iBaseId, self.m_iEquipLv, flag)
  for i = 1, 2 do
    local attrInfo = attrInfoList[i]
    if attrInfo and attrInfo.cfg then
      ResourceUtil:CreatePropertyImg(self["m_icon_attributes0" .. i .. "_Image"], attrInfo.id)
      local attrCfg = attrInfo.cfg
      self["m_txt_attributes0" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
      self["m_txt_num_before0" .. i .. "_Text"].text = tostring(attrInfo.num)
    end
  end
  if flag then
    UILuaHelper.SetColor(self.m_icon_equip_camp_Image, 216, 188, 69, 1)
  else
    UILuaHelper.SetColor(self.m_icon_equip_camp_Image, 0, 0, 0, 1)
  end
end

function Form_EquipmentTips:RefreshEquipCampInfo()
  local cfg = EquipManager:GetEquipCfgByBaseId(self.m_iBaseId)
  if cfg.m_BonusCamp > 0 then
    self.m_pnl_camp:SetActive(true)
    local camp = cfg.m_BonusCamp
    local stItemData = CampCfgIns:GetValue_ByCampID(camp)
    if stItemData:GetError() then
      log.error("ResourceUtil createCampImg camp  " .. tostring(camp))
      return
    end
    if not stItemData.m_CampIcon then
      return
    end
    CS.UI.UILuaHelper.SetAtlasSprite(self.m_icon_equip_camp_Image, stItemData.m_CampIcon, nil, nil, true)
    self.m_txt_camp_name_Text.text = stItemData.m_mCampName
  else
    self.m_pnl_camp:SetActive(false)
  end
end

function Form_EquipmentTips:OnEventUnInstallEquip()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTTIPS)
end

function Form_EquipmentTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_EquipmentTips:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTTIPS)
end

function Form_EquipmentTips:OnBtntakeoffClicked()
  if self.tParam.iHeroId ~= 0 and self.m_selPos ~= 0 then
    EquipManager:ReqUnInstallEquip(self.tParam.iHeroId, self.m_selPos)
  end
end

function Form_EquipmentTips:OnBtnchangeClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTTIPS)
  self:broadcastEvent("eGameEvent_Equip_ChangeEquip", self.m_selPos)
end

function Form_EquipmentTips:OnBtnupgradeClicked()
  StackPopup:Push(UIDefines.ID_FORM_EQUIPMENTUPGRADE, self.tParam)
  self:OnBtnCloseClicked()
end

function Form_EquipmentTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentTips", Form_EquipmentTips)
return Form_EquipmentTips
