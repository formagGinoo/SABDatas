local Form_Activity101Lamia_ShardItem = class("Form_Activity101Lamia_ShardItem", require("UI/UIFrames/Form_Activity101Lamia_ShardItemUI"))

function Form_Activity101Lamia_ShardItem:SetInitParam(param)
end

function Form_Activity101Lamia_ShardItem:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity101Lamia_ShardItem:OnActive()
  self.super.OnActive(self)
  local paramTab = self.m_csui.m_param
  self.item_id = paramTab.item_id
  self.m_backFun = paramTab.backFun
  if not self.item_id then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(145)
  local config = ItemManager:GetItemConfigById(self.item_id)
  UILuaHelper.SetAtlasSprite(self.m_img_item_Image, ItemManager:GetItemIconPathByID(self.item_id))
  self.m_txt_title_Text.text = ItemManager:GetItemName(self.item_id)
  self.m_txt_des_Text.text = config.m_mItemDesc
end

function Form_Activity101Lamia_ShardItem:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity101Lamia_ShardItem:OnBtncloseClicked()
  self:CloseForm()
  if self.m_backFun then
    self.m_backFun()
  end
end

function Form_Activity101Lamia_ShardItem:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity101Lamia_ShardItem:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_ShardItem", Form_Activity101Lamia_ShardItem)
return Form_Activity101Lamia_ShardItem
