local UIItemBase = require("UI/Item/LamiaLevel/UIHeroActLevelBase")
local UI112NormalLevelItem = class("UI112NormalLevelItem", UIItemBase)
local posEnum = {
  [0] = Vector2.New(0, 118),
  [1] = Vector2.New(0, -202)
}

function UI112NormalLevelItem:InitComponent()
  local itemTrans = self.m_itemRootObj.transform
  local item_nml = itemTrans:Find("item_nml")
  if not utils.isNull(item_nml) then
    self.m_itemTrans = item_nml:GetComponent("RectTransform")
  end
  self.m_normal_bg = itemTrans:Find("item_nml/item_normal")
  self.m_hard_bg = itemTrans:Find("item_nml/item_hard")
  self.m_normal_border = itemTrans:Find("item_nml/item_normal/c_bg_name1")
  self.m_hard_border = itemTrans:Find("item_nml/item_hard/bg_hard1")
  self.m_txt_level_name = self.m_itemTemplateCache:TMPPro("c_txt_name")
  self.name_color = self.m_txt_level_name:GetComponent("MultiColorChange")
  self.m_txt_level_title = self.m_itemTemplateCache:TMPPro("c_txt_name_num")
  self.name_color_title = self.m_txt_level_title:GetComponent("MultiColorChange")
  self.m_bg_lock = itemTrans:Find("item_nml/bg_lock")
  self.m_bg_lock_hard = itemTrans:Find("item_nml/bg_lock_hard")
  self.m_choose_image = self.m_itemTemplateCache:GameObject("c_img_icondone")
  self.m_repeat_tag = itemTrans:Find("item_nml/btn_icon_repeat")
  self.m_img_icon = itemTrans:Find("item_nml/bg_icon"):GetComponent(T_Image)
  local btn_touch = itemTrans:Find("item_nml/btn_touch")
  if not utils.isNull(btn_touch) then
    self.m_btn_Extension = btn_touch:GetComponent("ButtonExtensions")
    self.m_btn_Extension.Clicked = handler(self, self.OnBtnItemClk)
  end
  local btn_repeat = itemTrans:Find("item_nml/btn_icon_repeat")
  if not utils.isNull(btn_repeat) then
    self.m_btn_repeat = btn_repeat:GetComponent("ButtonExtensions")
    self.m_btn_repeat.Clicked = handler(self, self.OnBtnRepeatClk)
  end
end

function UI112NormalLevelItem:OnFreshData()
  UI112NormalLevelItem.super.OnFreshData(self)
  self:CheckShowUnlockAnim()
end

function UI112NormalLevelItem:FreshItemUI()
  UI112NormalLevelItem.super.FreshItemUI(self)
  if not utils.isNull(self.m_normal_border) then
    UILuaHelper.SetActive(self.m_normal_border, self.m_levelCfg.m_UIType ~= 1 or self.m_itemIndex ~= 1)
  end
  if not utils.isNull(self.m_hard_border) then
    UILuaHelper.SetActive(self.m_hard_border, self.m_levelCfg.m_UIType ~= 2 or self.m_itemIndex ~= 1)
  end
  self.m_itemTrans.anchoredPosition = posEnum[self.m_itemIndex % 2]
end

function UI112NormalLevelItem:ChangeChoose(isChoose)
  UI112NormalLevelItem.super.ChangeChoose(self, isChoose)
  if not utils.isNull(self.m_normal_bg) then
    UILuaHelper.SetActive(self.m_normal_bg, self.m_levelCfg.m_UIType == 1 and not isChoose and self.m_isUnlock)
  end
  if not utils.isNull(self.m_hard_bg) then
    UILuaHelper.SetActive(self.m_hard_bg, self.m_levelCfg.m_UIType == 2 and not isChoose and self.m_isUnlock)
  end
  self.name_color:SetColorByIndex(isChoose and 1 or 0)
  self.name_color_title:SetColorByIndex(isChoose and 1 or 0)
end

function UI112NormalLevelItem:CheckShowUnlockAnim()
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  if not self.m_isUnlock or self.m_parentLua.bIsShowDraw then
    return
  end
  local sKey = "UI112NormalLevelItem_UnlockAnim_" .. self.m_levelCfg.m_LevelID
  local bIsShowAnim = LocalDataManager:GetIntSimple(sKey, 0)
  if bIsShowAnim == 1 then
    return
  end
  LocalDataManager:SetIntSimple(sKey, 1)
  local tempObj = self.m_levelCfg.m_UIType == 1 and self.m_bg_lock or self.m_bg_lock_hard
  if not utils.isNull(tempObj) then
    UILuaHelper.SetActive(tempObj, true)
  end
  local sAniName = self.m_levelCfg.m_UIType == 1 and "Activity112_DialogueMain_in" or "Activity112_DialogueMain_Hard_in"
  UILuaHelper.PlayAnimationByName(self.m_itemTrans, sAniName)
  local fAniLength = UILuaHelper.GetAnimationLengthByName(self.m_itemTrans, sAniName)
  self.m_timer = TimeService:SetTimer(fAniLength, 1, function()
    if not utils.isNull(tempObj) then
      UILuaHelper.SetActive(tempObj, false)
    end
  end)
end

return UI112NormalLevelItem
