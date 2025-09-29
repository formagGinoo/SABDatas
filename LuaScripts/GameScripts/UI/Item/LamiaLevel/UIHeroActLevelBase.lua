local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroActLevelBase = class("UIHeroActLevelBase", UIItemBase)
local posEnum = {
  [0] = Vector2.New(0, 100),
  [1] = Vector2.New(0, -41)
}

function UIHeroActLevelBase:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
    self.m_parentLua = self.m_itemInitData.parentLua
  end
  self.m_levelCfg = nil
  self.m_isChoose = false
  self.m_isUnlock = false
  self.m_unlockStr = nil
  self.m_activitySubType = nil
  self:InitComponent()
end

function UIHeroActLevelBase:InitComponent()
end

function UIHeroActLevelBase:OnFreshData()
  self.m_levelCfg = self.m_itemData.levelCfg
  self.m_isChoose = self.m_itemData.isChoose
  self.m_isUnlock, _, self.m_unlockStr = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelUnLock(self.m_levelCfg.m_LevelID)
  self:FreshItemUI()
  self:ChangeChoose(self.m_isChoose)
  UILuaHelper.SetChildIndex(self.m_itemRootObj, self.m_itemIndex)
  local bIsCurrent = self.m_itemData.bIsCurrent
  if not utils.isNull(self.m_choose_image) then
    UILuaHelper.SetActive(self.m_choose_image, bIsCurrent)
  end
  if not utils.isNull(self.m_choose_image_hard) then
    UILuaHelper.SetActive(self.m_choose_image_hard, bIsCurrent)
  end
end

function UIHeroActLevelBase:FreshItemUI()
  if not self.m_levelCfg then
    return
  end
  local levelCfg = self.m_levelCfg
  if not utils.isNull(self.m_txt_level_title) then
    self.m_txt_level_title.text = levelCfg.m_LevelRef
  end
  if not utils.isNull(self.m_txt_level_name) then
    self.m_txt_level_name.text = levelCfg.m_mLevelName
  end
  self.m_activitySubType = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_levelCfg.m_LevelID)
  if not utils.isNull(self.m_repeat_tag) then
    UILuaHelper.SetActive(self.m_repeat_tag, levelCfg.m_Repeat == 1)
  end
  if not utils.isNull(self.m_bg_lock) then
    UILuaHelper.SetActive(self.m_bg_lock, self.m_levelCfg.m_UIType == 1 and self.m_isUnlock ~= true)
  end
  if not utils.isNull(self.m_bg_lock_hard) then
    UILuaHelper.SetActive(self.m_bg_lock_hard, self.m_levelCfg.m_UIType == 2 and self.m_isUnlock ~= true)
  end
  if not utils.isNull(self.m_normal_bg) then
    UILuaHelper.SetActive(self.m_normal_bg, self.m_levelCfg.m_UIType == 1)
  end
  if not utils.isNull(self.m_hard_bg) then
    UILuaHelper.SetActive(self.m_hard_bg, self.m_levelCfg.m_UIType == 2)
  end
  if not utils.isNull(self.m_img_line_up) then
    self.m_img_line_up:SetActive(self.m_itemData.maxNum ~= self.m_itemIndex and self.m_itemIndex % 2 ~= 0)
  end
  if not utils.isNull(self.m_img_line_down) then
    self.m_img_line_down:SetActive(self.m_itemData.maxNum ~= self.m_itemIndex and self.m_itemIndex % 2 == 0)
  end
  if not utils.isNull(self.m_itemTrans) then
    self.m_itemTrans.anchoredPosition = posEnum[self.m_itemIndex % 2]
  end
end

function UIHeroActLevelBase:ChangeChoose(isChoose)
  self.m_isChoose = isChoose
  self.m_itemData.isChoose = isChoose
  if not self.m_levelCfg then
    return
  end
  if not utils.isNull(self.m_bg_name_select) then
    UILuaHelper.SetActive(self.m_bg_name_select, self.m_levelCfg.m_UIType == 1 and isChoose)
  end
  if not utils.isNull(self.m_bg_name_hard_select) then
    UILuaHelper.SetActive(self.m_bg_name_hard_select, self.m_levelCfg.m_UIType == 2 and isChoose)
  end
end

function UIHeroActLevelBase:OnBtnItemClk()
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

function UIHeroActLevelBase:GetCostItemNameStr()
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_levelCfg.m_ActivityID)
  local costItemID = mainActInfoCfg.m_PassItem
  return ItemManager:GetItemName(costItemID)
end

function UIHeroActLevelBase:OnBtnRepeatClk()
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
    local costItemNameStr = self:GetCostItemNameStr()
    utils.CheckAndPushCommonTips({
      tipsID = 3001,
      bLockBack = true,
      fContentCB = function(sContent)
        return string.CS_Format(sContent, costItemNameStr)
      end,
      func1 = function()
        local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_levelCfg.m_ActivityID)
        local jumpIns = ConfigManager:GetConfigInsByName("Jump")
        local jump_item = jumpIns:GetValue_ByJumpID(mainActInfoCfg.m_ShopJumpID)
        local windowId = jump_item.m_Param.Length > 0 and tonumber(jump_item.m_Param[0]) or 0
        local shop_list = ShopManager:GetShopConfigList(ShopManager.ShopType.ShopType_Activity)
        local shop_id
        for i, v in ipairs(shop_list) do
          if v.m_WindowID == windowId then
            shop_id = v.m_ShopID
          end
        end
        local is_corved, t1, t2 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.shop, {
          id = self.m_levelCfg.m_ActivityID,
          shop_id = shop_id
        })
        if is_corved and not TimeUtil:IsInTime(t1, t2) then
          StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10107)
          return
        end
        self.m_parentLua.bIsWaitingShopData = true
        ShopManager:ReqGetShopData(shop_id)
      end
    })
    return
  end
  local isChallenge = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(m_levelCfg.m_LevelID) == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if totalTimes <= 1 or isChallenge then
    LevelHeroLamiaActivityManager:ReqLamiaStageSweep(m_levelCfg.m_ActivityID, m_levelCfg.m_LevelID, 1)
  else
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_DIALOGUEFASTPASS, {
      activityID = m_levelCfg.m_ActivityID,
      subActivityID = m_levelCfg.m_ActivitySubID,
      levelID = m_levelCfg.m_LevelID
    })
  end
end

function UIHeroActLevelBase:IsHaveEnoughTimes()
  local itemNum = self:GetCostItemNum() or 0
  return 0 < itemNum, itemNum
end

function UIHeroActLevelBase:GetCostItemNum()
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

function UIHeroActLevelBase:dispose()
  if self.m_timer then
    TimeService:KillTimer(self.m_timer)
    self.m_timer = nil
  end
end

return UIHeroActLevelBase
