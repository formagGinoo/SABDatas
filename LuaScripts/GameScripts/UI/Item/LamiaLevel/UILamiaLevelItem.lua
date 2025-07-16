local UIItemBase = require("UI/Common/UIItemBase")
local UILamiaLevelItem = class("UILamiaLevelItem", UIItemBase)

function UILamiaLevelItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  local itemTrans = self.m_itemRootObj.transform
  self.m_img_icon = itemTrans:Find("mask/icon"):GetComponent(T_Image)
  self.m_node_frame = itemTrans:Find("frame")
  self.m_bg_lock = itemTrans:Find("bg_lock")
  self.m_img_nml_light = itemTrans:Find("img_nml_light")
  self.m_img_boss_light = itemTrans:Find("img_boss_light")
  self.m_choose_image = itemTrans:Find("bg_name/icon_sel")
  self.m_repeat_tag = itemTrans:Find("icon_repeat")
  self.m_txt_level_title = itemTrans:Find("bg_name/c_txt_name_num"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_level_name = itemTrans:Find("bg_name/c_txt_name"):GetComponent(T_TextMeshProUGUI)
  self.m_btn_Extension = itemTrans:Find("btn_touch"):GetComponent("ButtonExtensions")
  self.m_btn_Extension.Clicked = handler(self, self.OnBtnItemClk)
  self.m_btn_repeat = itemTrans:Find("icon_repeat"):GetComponent("ButtonExtensions")
  self.m_btn_repeat.Clicked = handler(self, self.OnBtnRepeatClk)
  self.m_levelCfg = nil
  self.m_isChoose = false
  self.m_isUnlock = false
  self.m_unlockStr = nil
  self.m_activitySubType = nil
end

function UILamiaLevelItem:OnFreshData()
  self.m_levelCfg = self.m_itemData.levelCfg
  self.m_isChoose = self.m_itemData.isChoose
  self.m_isUnlock, _, self.m_unlockStr = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelUnLock(self.m_levelCfg.m_LevelID)
  self:FreshItemUI()
  self:ChangeChoose(self.m_isChoose)
end

function UILamiaLevelItem:FreshItemUI()
  if not self.m_levelCfg then
    return
  end
  local levelCfg = self.m_levelCfg
  self.m_txt_level_title.text = levelCfg.m_LevelRef
  self.m_txt_level_name.text = levelCfg.m_mLevelName
  self.m_activitySubType = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_levelCfg.m_LevelID)
  UILuaHelper.SetAtlasSprite(self.m_img_icon, levelCfg.m_UIPic)
  UILuaHelper.SetActive(self.m_img_nml_light, levelCfg.m_Elite ~= 1)
  UILuaHelper.SetActive(self.m_img_boss_light, levelCfg.m_Elite == 1)
  UILuaHelper.SetActive(self.m_repeat_tag, levelCfg.m_Repeat == 1)
  UILuaHelper.SetActive(self.m_bg_lock, self.m_isUnlock ~= true)
  local colorIndex = self.m_activitySubType == HeroActivityManager.SubActTypeEnum.NormalLevel and 0 or 1
  UILuaHelper.SetColorByMultiIndex(self.m_node_frame, colorIndex)
end

function UILamiaLevelItem:ChangeChoose(isChoose)
  self.m_isChoose = isChoose
  self.m_itemData.isChoose = isChoose
  UILuaHelper.SetActive(self.m_choose_image, isChoose)
end

function UILamiaLevelItem:OnBtnItemClk()
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
  if self.m_isChoose ~= true then
    self:ChangeChoose(true)
  end
end

function UILamiaLevelItem:OnBtnRepeatClk()
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

function UILamiaLevelItem:IsHaveEnoughTimes()
  local m_levelCfg = self.m_levelCfg
  local leftTimes = LevelHeroLamiaActivityManager:GetLevelHelper():GetLeftFreeTimes(m_levelCfg.m_ActivityID, m_levelCfg.m_ActivitySubID) or 0
  local itemNum = self:GetCostItemNum() or 0
  return 0 < leftTimes + itemNum, leftTimes + itemNum
end

function UILamiaLevelItem:GetCostItemNum()
  local isChallenge = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_levelCfg.m_LevelID) == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if isChallenge then
    return
  end
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_levelCfg.m_ActivityID)
  local costItemID = mainActInfoCfg.m_PassItem
  local costItemNum = ItemManager:GetItemNum(costItemID)
  return costItemNum
end

return UILamiaLevelItem
