local UIItemBase = require("UI/Common/UIItemBase")
local UIDalcaroItem = class("UIDalcaroItem", UIItemBase)
local posEnum = {
  [0] = Vector2.New(0, 55),
  [1] = Vector2.New(0, -160)
}

function UIDalcaroItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  local itemTrans = self.m_itemRootObj.transform
  self.m_itemTrans = itemTrans:Find("item_nml"):GetComponent("RectTransform")
  self.m_img_icon = self.m_mask.transform:Find("icon"):GetComponent(T_Image)
  self.m_img_hard_icon = self.m_mask_hard.transform:Find("icon"):GetComponent(T_Image)
  self.m_bg_lock = itemTrans:Find("item_nml/bg_lock")
  self.m_img_nml_light = itemTrans:Find("item_nml/img_nml_light").gameObject
  self.m_img_boss_light = itemTrans:Find("item_nml/img_boss_light").gameObject
  self.m_choose_image = itemTrans:Find("item_nml/c_txt_name_num/c_img_icondone")
  self.m_repeat_tag = itemTrans:Find("item_nml/btn_icon_repeat")
  self.m_txt_level_title = itemTrans:Find("item_nml/c_txt_name_num"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_level_name = itemTrans:Find("item_nml/c_txt_name"):GetComponent(T_TextMeshProUGUI)
  self.m_btn_Extension = itemTrans:Find("item_nml/btn_touch"):GetComponent("ButtonExtensions")
  self.m_btn_repeat = itemTrans:Find("item_nml/btn_icon_repeat"):GetComponent("ButtonExtensions")
  self.m_btn_Extension.Clicked = handler(self, self.OnBtnItemClk)
  self.m_btn_repeat.Clicked = handler(self, self.OnBtnRepeatClk)
  self.m_levelCfg = nil
  self.m_isChoose = false
  self.m_isUnlock = false
  self.m_unlockStr = nil
  self.m_activitySubType = nil
end

function UIDalcaroItem:OnFreshData()
  self.m_levelCfg = self.m_itemData.levelCfg
  self.m_isChoose = self.m_itemData.isChoose
  self.m_isUnlock, _, self.m_unlockStr = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelUnLock(self.m_levelCfg.m_LevelID)
  self:FreshItemUI()
  self:ChangeChoose(self.m_isChoose)
  UILuaHelper.SetChildIndex(self.m_itemRootObj, self.m_itemIndex)
end

function UIDalcaroItem:FreshItemUI()
  if not self.m_levelCfg then
    return
  end
  local levelCfg = self.m_levelCfg
  self.m_txt_level_title.text = levelCfg.m_LevelRef
  self.m_txt_level_name.text = levelCfg.m_mLevelName
  self.m_activitySubType = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_levelCfg.m_LevelID)
  UILuaHelper.SetActive(self.m_img_nml_light, levelCfg.m_Elite ~= 1)
  UILuaHelper.SetActive(self.m_img_boss_light, levelCfg.m_Elite == 1)
  UILuaHelper.SetActive(self.m_repeat_tag, levelCfg.m_Repeat == 1)
  UILuaHelper.SetActive(self.m_bg_lock, self.m_isUnlock ~= true)
  UILuaHelper.SetActive(self.m_mask, levelCfg.m_UIType == 1 and self.m_isUnlock)
  UILuaHelper.SetActive(self.m_mask_hard, levelCfg.m_UIType ~= 1 and self.m_isUnlock)
  self.m_img_line_up:SetActive(self.m_itemData.maxNum ~= self.m_itemIndex and self.m_itemIndex % 2 ~= 0)
  self.m_img_line_down:SetActive(self.m_itemData.maxNum ~= self.m_itemIndex and self.m_itemIndex % 2 == 0)
  self.m_itemTrans.anchoredPosition = posEnum[self.m_itemIndex % 2]
  if levelCfg.m_Elite ~= 1 then
    self.m_frame:SetActive(true)
    self.m_frame_hard:SetActive(false)
  else
    self.m_frame:SetActive(false)
    self.m_frame_hard:SetActive(true)
  end
end

function UIDalcaroItem:ChangeChoose(isChoose)
  self.m_isChoose = isChoose
  self.m_itemData.isChoose = isChoose
  UILuaHelper.SetActive(self.m_choose_image, isChoose)
end

function UIDalcaroItem:OnBtnItemClk()
  if not self.m_itemData then
    return
  end
  if not self.m_isUnlock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_unlockStr)
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

function UIDalcaroItem:OnBtnRepeatClk()
  if not self.m_itemData then
    return
  end
  if not self.m_isUnlock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_unlockStr)
    return
  end
  local m_levelCfg = self.m_levelCfg
  local isHavePass = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(m_levelCfg.m_LevelID)
  if isHavePass ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40037)
    return
  end
  local isHaveEnough, totalTimes = self:IsHaveEnoughTimes()
  if isHaveEnough ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40038)
    return
  end
  local isChallenge = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(m_levelCfg.m_LevelID) == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if totalTimes <= 1 or isChallenge then
    LevelHeroLamiaActivityManager:ReqLamiaStageSweep(m_levelCfg.m_ActivityID, m_levelCfg.m_LevelID, 1)
  else
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUEFASTPASS, {
      activityID = m_levelCfg.m_ActivityID,
      subActivityID = m_levelCfg.m_ActivitySubID,
      levelID = m_levelCfg.m_LevelID
    })
  end
end

function UIDalcaroItem:IsHaveEnoughTimes()
  local m_levelCfg = self.m_levelCfg
  local leftTimes = LevelHeroLamiaActivityManager:GetLevelHelper():GetLeftFreeTimes(m_levelCfg.m_ActivityID, m_levelCfg.m_ActivitySubID) or 0
  local itemNum = self:GetCostItemNum() or 0
  return 0 < leftTimes + itemNum, leftTimes + itemNum
end

function UIDalcaroItem:GetCostItemNum()
  local isChallenge = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_levelCfg.m_LevelID) == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if isChallenge then
    return
  end
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_levelCfg.m_ActivityID)
  local costItemID = mainActInfoCfg.m_PassItem
  local costItemNum = ItemManager:GetItemNum(costItemID) or 0
  local freeItemId = mainActInfoCfg.m_FreePassItem
  local freeitemNum = ItemManager:GetItemNum(freeItemId) or 0
  return costItemNum + freeitemNum
end

return UIDalcaroItem
