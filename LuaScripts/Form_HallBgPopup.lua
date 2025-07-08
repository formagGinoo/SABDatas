local Form_HallBgPopup = class("Form_HallBgPopup", require("UI/UIFrames/Form_HallBgPopupUI"))
local BackGroundIns = ConfigManager:GetConfigInsByName("MainBackground")

function Form_HallBgPopup:SetInitParam(param)
end

function Form_HallBgPopup:AfterInit()
  self.super.AfterInit(self)
end

function Form_HallBgPopup:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
end

function Form_HallBgPopup:OnInactive()
  self.super.OnInactive(self)
end

function Form_HallBgPopup:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HallBgPopup:RefreshUI()
  local tParam = self.m_csui.m_param
  if not tParam or not tParam.bgId then
    self:CloseForm()
    return
  end
  local bgCfg = BackGroundIns:GetValue_ByBDID(tParam.bgId)
  if bgCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_bg_Image, bgCfg.m_SmallPic)
  self.m_txt_middle_title_Text.text = bgCfg.m_mItemName
  self.m_txt_unlock_Text.text = bgCfg.m_mGetwayDes
  self.m_txt_bginfor_Text.text = bgCfg.m_mItemDec
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_infor)
  self.id = bgCfg.m_BDID
  local num = ItemManager:GetItemNum(self.id, true)
  UILuaHelper.SetActive(self.m_pnl_own, 0 < num)
end

function Form_HallBgPopup:OnBtnprvClicked()
  local curData = {
    iId = self.id,
    iType = RoleManager.MainBgType.Activity
  }
  StackFlow:Push(UIDefines.ID_FORM_HALLDECORATESHOW, {mainBgData = curData})
  self:CloseForm()
end

function Form_HallBgPopup:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HallBgPopup", Form_HallBgPopup)
return Form_HallBgPopup
