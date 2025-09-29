local UIItemBase = require("UI/Item/LamiaLevel/UIHeroActLevelBase")
local UI110NormalLevelItem = class("UI110NormalLevelItem", UIItemBase)
local posEnum = {
  [0] = Vector2.New(0, 50),
  [1] = Vector2.New(0, -163)
}

function UI110NormalLevelItem:InitComponent()
  local itemTrans = self.m_itemRootObj.transform
  local item_nml = itemTrans:Find("item_nml")
  if not utils.isNull(item_nml) then
    self.m_itemTrans = item_nml:GetComponent("RectTransform")
  end
  self.m_normal_bg = itemTrans:Find("item_nml/bg_name")
  self.m_hard_bg = itemTrans:Find("item_nml/bg_name_hard")
  self.m_txt_level_name = self.m_itemTemplateCache:TMPPro("c_txt_name")
  self.m_txt_level_title = self.m_itemTemplateCache:TMPPro("c_txt_name_num")
  self.m_txt_level_title_hard = self.m_itemTemplateCache:TMPPro("c_txt_name_num_hard")
  self.m_img_bglevel = self.m_itemTemplateCache:GameObject("c_img_bgname")
  self.m_img_bglevel_hard = self.m_itemTemplateCache:GameObject("c_img_bgname_hard")
  self.m_bg_lock = itemTrans:Find("item_nml/bg_lock")
  self.m_bg_lock_hard = itemTrans:Find("item_nml/bg_lock_hard")
  self.m_bg_done = itemTrans:Find("item_nml/bg_done")
  self.m_bg_done_hard = itemTrans:Find("item_nml/bg_done_hard")
  self.m_choose_image = self.m_itemTemplateCache:GameObject("c_img_icondone")
  self.m_choose_image_hard = self.m_itemTemplateCache:GameObject("c_img_icondone_hard")
  self.m_repeat_tag = itemTrans:Find("item_nml/btn_icon_repeat")
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

function UI110NormalLevelItem:OnFreshData()
  UI110NormalLevelItem.super.OnFreshData(self)
  self:CheckShowUnlockAnim()
end

function UI110NormalLevelItem:FreshItemUI()
  UI110NormalLevelItem.super.FreshItemUI(self)
  if not utils.isNull(self.m_img_line_up) then
    self.m_img_line_up:SetActive(false)
  end
  if not utils.isNull(self.m_img_line_down) then
    self.m_img_line_down:SetActive(false)
  end
  local bIsHard = self.m_levelCfg.m_UIType == 2
  local bIsPass = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(self.m_levelCfg.m_LevelID)
  if not utils.isNull(self.m_bg_done) then
    UILuaHelper.SetActive(self.m_bg_done, bIsPass and not bIsHard)
  end
  if not utils.isNull(self.m_bg_done_hard) then
    UILuaHelper.SetActive(self.m_bg_done_hard, bIsPass and bIsHard)
  end
  if not utils.isNull(self.m_normal_bg) then
    UILuaHelper.SetActive(self.m_normal_bg, self.m_levelCfg.m_UIType == 1 and not bIsPass)
  end
  if not utils.isNull(self.m_hard_bg) then
    UILuaHelper.SetActive(self.m_hard_bg, self.m_levelCfg.m_UIType == 2 and not bIsPass)
  end
  local levelCfg = self.m_levelCfg
  if not utils.isNull(self.m_txt_level_title) then
    self.m_txt_level_title.text = levelCfg.m_LevelRef
  end
  if not utils.isNull(self.m_txt_level_title_hard) then
    self.m_txt_level_title_hard.text = levelCfg.m_LevelRef
  end
  if not utils.isNull(self.m_img_bglevel) then
    UILuaHelper.SetActive(self.m_img_bglevel, not bIsHard)
  end
  if not utils.isNull(self.m_img_bglevel_hard) then
    UILuaHelper.SetActive(self.m_img_bglevel_hard, bIsHard)
  end
  self.m_itemTrans.anchoredPosition = posEnum[self.m_itemIndex % 2]
end

function UI110NormalLevelItem:ChangeChoose(isChoose)
  UI110NormalLevelItem.super.ChangeChoose(self, isChoose)
  local bIsPass = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(self.m_levelCfg.m_LevelID)
  if not utils.isNull(self.m_bg_name_select) then
    UILuaHelper.SetActive(self.m_bg_name_select, self.m_levelCfg.m_UIType == 1 and isChoose and not bIsPass)
  end
  if not utils.isNull(self.m_bg_name_hard_select) then
    UILuaHelper.SetActive(self.m_bg_name_hard_select, self.m_levelCfg.m_UIType == 2 and isChoose and not bIsPass)
  end
  if not utils.isNull(self.m_img_donesel) then
    UILuaHelper.SetActive(self.m_img_donesel, self.m_levelCfg.m_UIType == 1 and isChoose and bIsPass)
  end
  if not utils.isNull(self.m_img_donesel_hard) then
    UILuaHelper.SetActive(self.m_img_donesel_hard, self.m_levelCfg.m_UIType == 2 and isChoose and bIsPass)
  end
end

function UI110NormalLevelItem:CheckShowUnlockAnim()
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
  if not self.m_isUnlock then
    return
  end
  local sKey = "UI110NormalLevelItem_UnlockAnim_" .. self.m_levelCfg.m_LevelID
  local bIsShowAnim = LocalDataManager:GetIntSimple(sKey, 0)
  if bIsShowAnim == 1 then
    return
  end
  LocalDataManager:SetIntSimple(sKey, 1)
  local tempObj = self.m_levelCfg.m_UIType == 1 and self.m_bg_lock or self.m_bg_lock_hard
  if not utils.isNull(tempObj) then
    UILuaHelper.SetActive(tempObj, true)
  end
  local sAniName = self.m_levelCfg.m_UIType == 1 and "Activity110_DialogueMain_in" or "Activity110_DialogueMain_Hard_in"
  UILuaHelper.PlayAnimationByName(self.m_itemTrans, sAniName)
  local fAniLength = UILuaHelper.GetAnimationLengthByName(self.m_itemTrans, sAniName)
  self.m_timer = TimeService:SetTimer(fAniLength, 1, function()
    if not utils.isNull(tempObj) then
      UILuaHelper.SetActive(tempObj, false)
    end
  end)
end

return UI110NormalLevelItem
