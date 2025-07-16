local Form_EquipmentUpgradeTips = class("Form_EquipmentUpgradeTips", require("UI/UIFrames/Form_EquipmentUpgradeTipsUI"))
local EquipLevelIns = ConfigManager:GetConfigInsByName("EquipLevel")
local OPEN_ANIM_NAME = "EquipmentUpgradeTips_in"

function Form_EquipmentUpgradeTips:SetInitParam(param)
end

function Form_EquipmentUpgradeTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_EquipmentUpgradeTips:OnActive()
  self.super.OnActive(self)
  self.m_param = self.m_csui.m_param
  self.m_equipId = self.m_param.equip_id
  self.m_beforeLv = self.m_param.before_lv or 0
  self.m_afterLv = self.m_param.after_lv or 0
  self:RefreshUI()
end

function Form_EquipmentUpgradeTips:RefreshUI()
  local equipData = EquipManager:GetEquipDataByID(self.m_equipId)
  local flag = EquipManager:CheckIsShowCampAttAddExt(self.m_equipId)
  local attrInfoList = {}
  local afterAttrInfoList = {}
  if equipData.iOverloadHero ~= 0 then
    attrInfoList = EquipManager:GetEquipOverLoadBaseAttr(equipData.iBaseId, self.m_beforeLv)
    afterAttrInfoList = EquipManager:GetEquipOverLoadBaseAttr(equipData.iBaseId, self.m_afterLv)
  else
    attrInfoList = EquipManager:GetEquipBaseAttr(equipData.iBaseId, self.m_beforeLv, flag)
    afterAttrInfoList = EquipManager:GetEquipBaseAttr(equipData.iBaseId, self.m_afterLv, flag)
  end
  for i = 1, 2 do
    local attrInfo = attrInfoList[i]
    if attrInfo and attrInfo.cfg then
      ResourceUtil:CreatePropertyImg(self["m_icon_sx" .. i .. "_Image"], attrInfo.id)
      local attrCfg = attrInfo.cfg
      self["m_txt_sx_name" .. i .. "_Text"].text = tostring(attrCfg.m_mCNName)
      self["m_before_sx_num" .. i .. "_Text"].text = tostring(attrInfo.num)
    end
    if afterAttrInfoList then
      local afterAttrInfo = afterAttrInfoList[i]
      if afterAttrInfo then
        self["m_after_sx_num" .. i .. "_Text"].text = tostring(afterAttrInfo.num)
      end
    else
      self["m_img_arrow" .. i]:SetActive(false)
      self["m_after_sx_num" .. i .. "_Text"].text = ""
    end
  end
  self.m_txt_lv_before_Text.text = string.format(ConfigManager:GetCommonTextById(20033), tostring(self.m_beforeLv))
  self.m_txt_lv_after_Text.text = string.format(ConfigManager:GetCommonTextById(20033), tostring(self.m_afterLv))
  self.m_txt_upgrade_icon_num_Text.text = tostring(self.m_afterLv)
  local equipCfg = EquipManager:GetEquipCfgByBaseId(equipData.iBaseId)
  if not equipData then
    log.error("RefreshUpgradeEquipment GetEquipDataByID is error")
    return
  end
  local levelTemplateID = equipData.iOverloadHero == 0 and equipCfg.m_LevelTemplate or equipCfg.m_OverloadLevelTemplate
  local lvCfg = EquipLevelIns:GetValue_ByEquipLevelTemplateAndEquipLevel(levelTemplateID, equipData.iLevel)
  if not lvCfg:GetError() then
    self.m_img_max:SetActive(lvCfg.m_EXPConsume == 0)
  end
end

function Form_EquipmentUpgradeTips:IsOpenGuassianBlur()
  return true
end

function Form_EquipmentUpgradeTips:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  if UILuaHelper.IsAnimationPlaying(self.m_csui.m_uiGameObject) then
    UILuaHelper.ResetAnimationByName(self.m_csui.m_uiGameObject, OPEN_ANIM_NAME, -1)
    return
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_EQUIPMENTUPGRADETIPS)
  if self.m_param and self.m_param.vReturnItem and next(self.m_param.vReturnItem) then
    utils.popUpRewardUI(self.m_param.vReturnItem)
  end
end

function Form_EquipmentUpgradeTips:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_EquipmentUpgradeTips", Form_EquipmentUpgradeTips)
return Form_EquipmentUpgradeTips
