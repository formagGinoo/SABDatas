local Form_CastleStatueDetails = class("Form_CastleStatueDetails", require("UI/UIFrames/Form_CastleStatueDetailsUI"))

function Form_CastleStatueDetails:SetInitParam(param)
end

function Form_CastleStatueDetails:AfterInit()
  self.super.AfterInit(self)
  self.all_statue_configs = StatueShowroomManager:GetAllCastleStatueCfg()
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
end

function Form_CastleStatueDetails:OnActive()
  self.super.OnActive(self)
  self.cur_index = self.m_csui.m_param or 1
  self:RefreshUI()
end

function Form_CastleStatueDetails:RefreshUI()
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, "CastleStatueDetails_cut")
  local config = self.all_statue_configs[self.cur_index]
  local server_data = StatueShowroomManager:GetServerData()
  local is_unlock = server_data.iLevel >= config.m_StatueLevel
  UILuaHelper.SetAtlasSprite(self.m_icon_sculpture_Image, config.m_StatuePic)
  UILuaHelper.SetAtlasSprite(self.m_icon_sculpture_gray_Image, config.m_StatuePic)
  self.m_item_lv_num_Text.text = config.m_StatueLevel
  self.m_txt_name_sculpture_Text.text = config.m_mStatueName
  self.m_txt_name_sculpture_grey_Text.text = config.m_mStatueName
  self.m_icon_sculpture:SetActive(is_unlock)
  self.m_icon_sculpture_gray:SetActive(not is_unlock)
  self.m_txt_name_sculpture:SetActive(is_unlock)
  self.m_txt_name_sculpture_grey:SetActive(not is_unlock)
  self.m_txt_unlock_function_Text.text = config.m_mStatueDes
  self.m_txt_unlock_Text.text = is_unlock and ConfigManager:GetCommonTextById(100083) or string.gsubnumberreplace(ConfigManager:GetCommonTextById(100082), config.m_StatueLevel)
  self.m_img_last_normal_gray:SetActive(not self.all_statue_configs[self.cur_index - 1])
  self.m_img_next_normal_gray:SetActive(not self.all_statue_configs[self.cur_index + 1])
end

function Form_CastleStatueDetails:OnBtnLClicked()
  if not self.all_statue_configs[self.cur_index - 1] then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40048)
    return
  end
  self.cur_index = self.cur_index - 1
  self:RefreshUI()
end

function Form_CastleStatueDetails:OnBtnRClicked()
  if not self.all_statue_configs[self.cur_index + 1] then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40048)
    return
  end
  self.cur_index = self.cur_index + 1
  self:RefreshUI()
end

function Form_CastleStatueDetails:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleStatueDetails:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStatueDetails:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleStatueDetails", Form_CastleStatueDetails)
return Form_CastleStatueDetails
