local Form_CastleStatueUnlockTips = class("Form_CastleStatueUnlockTips", require("UI/UIFrames/Form_CastleStatueUnlockTipsUI"))

function Form_CastleStatueUnlockTips:SetInitParam(param)
end

function Form_CastleStatueUnlockTips:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
end

function Form_CastleStatueUnlockTips:OnActive()
  self.super.OnActive(self)
  self.list = self.m_csui.m_param
  self.cur_idx = 1
  self.max_idx = #self.list
  self.m_btn_L:SetActive(1 < self.max_idx)
  self.m_btn_R:SetActive(1 < self.max_idx)
  self.show_list = {}
  self:RefreshUI()
end

function Form_CastleStatueUnlockTips:RefreshUI()
  if not self.show_list[self.cur_idx] then
    UILuaHelper.PlayAnimationByName(self.m_rootTrans, "CastleStatueUnlock_in")
    self.show_list[self.cur_idx] = true
  end
  self.m_img_last_normal_gray:SetActive(not self.list[self.cur_idx - 1])
  self.m_img_next_normal_gray:SetActive(not self.list[self.cur_idx + 1])
  local config = self.list[self.cur_idx]
  self.m_item_lv_num_Text.text = config.m_StatueLevel
  UILuaHelper.SetAtlasSprite(self.m_item_icon_Image, config.m_StatuePic)
  UILuaHelper.SetAtlasSprite(self.m_item_icon_lock_Image, config.m_StatuePic)
  self.m_txt_item_des_Text.text = config.m_mStatueDes
end

function Form_CastleStatueUnlockTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleStatueUnlockTips:OnBtnRClicked()
  if not self.list[self.cur_idx + 1] then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40048)
    return
  end
  self.cur_idx = self.cur_idx + 1
  self:RefreshUI()
end

function Form_CastleStatueUnlockTips:OnBtnLClicked()
  if not self.list[self.cur_idx - 1] then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40048)
    return
  end
  self.cur_idx = self.cur_idx - 1
  self:RefreshUI()
end

function Form_CastleStatueUnlockTips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CastleStatueUnlockTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStatueUnlockTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleStatueUnlockTips", Form_CastleStatueUnlockTips)
return Form_CastleStatueUnlockTips
