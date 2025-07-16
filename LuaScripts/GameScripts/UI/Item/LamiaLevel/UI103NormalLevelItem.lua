local UIItemBase = require("UI/Common/UIItemBase")
local UI103NormalLevelItem = class("UI103NormalLevelItem", UIItemBase)
local posEnum = {
  [0] = Vector2.New(0, 135),
  [1] = Vector2.New(0, -240)
}

function UI103NormalLevelItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
    self.m_parentLua = self.m_itemInitData.parentLua
  end
  local itemTrans = self.m_itemRootObj.transform
  local item_nml = itemTrans:Find("item_nml")
  if not utils.isNull(item_nml) then
    self.m_itemTrans = item_nml:GetComponent("RectTransform")
  end
  if not utils.isNull(self.m_mask) then
    local icon = self.m_mask.transform:Find("icon")
    if not utils.isNull(icon) then
      self.m_img_icon = icon:GetComponent(T_Image)
    end
  end
  if not utils.isNull(self.m_mask_hard) then
    local icon = self.m_mask_hard.transform:Find("icon")
    if not utils.isNull(icon) then
      self.m_img_hard_icon = icon:GetComponent(T_Image)
    end
  end
  self.m_bg_lock = itemTrans:Find("item_nml/bg_lock")
  self.m_choose_image = self.m_itemTemplateCache:GameObject("c_img_icondone")
  self.m_repeat_tag = itemTrans:Find("item_nml/btn_icon_repeat")
  self.m_txt_level_title = self.m_itemTemplateCache:TMPPro("c_txt_name_num")
  self.m_txt_level_name = self.m_itemTemplateCache:TMPPro("c_txt_name")
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
  self.m_levelCfg = nil
  self.m_isChoose = false
  self.m_isUnlock = false
  self.m_unlockStr = nil
  self.m_activitySubType = nil
end

function UI103NormalLevelItem:OnFreshData()
  self.m_levelCfg = self.m_itemData.levelCfg
  self.m_isChoose = self.m_itemData.isChoose
  self.m_isUnlock, _, self.m_unlockStr = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelUnLock(self.m_levelCfg.m_LevelID)
  self:FreshItemUI()
  self:ChangeChoose(self.m_isChoose)
end

function UI103NormalLevelItem:FreshItemUI()
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
    UILuaHelper.SetActive(self.m_bg_lock, self.m_isUnlock ~= true)
  end
  if not utils.isNull(self.m_img_line_up) then
    UILuaHelper.SetActive(self.m_img_line_up, self.m_itemData.maxNum ~= self.m_itemIndex and self.m_itemIndex % 2 ~= 0)
  end
  if not utils.isNull(self.m_img_line_down) then
    UILuaHelper.SetActive(self.m_img_line_down, self.m_itemData.maxNum ~= self.m_itemIndex and self.m_itemIndex % 2 == 0)
  end
  self.m_itemTrans.anchoredPosition = posEnum[self.m_itemIndex % 2]
end

function UI103NormalLevelItem:ChangeChoose(isChoose)
  self.m_isChoose = isChoose
  self.m_itemData.isChoose = isChoose
  if not utils.isNull(self.m_choose_image) then
    UILuaHelper.SetActive(self.m_choose_image, isChoose)
  end
  local levelCfg = self.m_levelCfg
  local sPicStr = isChoose and levelCfg.m_UIPic .. "_sel" or levelCfg.m_UIPic
  if not utils.isNull(self.m_img_icon) then
    UILuaHelper.SetAtlasSprite(self.m_img_icon, sPicStr)
  end
end

function UI103NormalLevelItem:OnBtnItemClk()
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

function UI103NormalLevelItem:GetCostItemNameStr()
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_levelCfg.m_ActivityID)
  local costItemID = mainActInfoCfg.m_PassItem
  return ItemManager:GetItemName(costItemID)
end

function UI103NormalLevelItem:OnBtnRepeatClk()
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
        local windowId = tonumber(jump_item.m_Param[0])
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

function UI103NormalLevelItem:IsHaveEnoughTimes()
  local itemNum = self:GetCostItemNum() or 0
  return 0 < itemNum, itemNum
end

function UI103NormalLevelItem:GetCostItemNum()
  local isChallenge = LevelHeroLamiaActivityManager:GetActivitySubTypeByID(self.m_levelCfg.m_LevelID) == HeroActivityManager.SubActTypeEnum.ChallengeLevel
  if isChallenge then
    return
  end
  local mainActInfoCfg = HeroActivityManager:GetMainInfoByActID(self.m_levelCfg.m_ActivityID)
  local costItemID = mainActInfoCfg.m_PassItem
  local costItemNum = ItemManager:GetItemNum(costItemID)
  return costItemNum
end

return UI103NormalLevelItem
