local UIItemBase = require("UI/Common/UIItemBase")
local UILamiaChallengeLevelItem = class("UILamiaChallengeLevelItem", UIItemBase)

function UILamiaChallengeLevelItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelCfg = nil
  self.m_isChoose = false
  self.m_isUnlock = false
  self.m_unlockStr = nil
  self.m_isPass = nil
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  self.m_keyWardItemWidget = self:createCommonItem(self.m_common_item)
  self.m_keyWardItemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
end

function UILamiaChallengeLevelItem:OnFreshData()
  self.m_levelCfg = self.m_itemData.levelCfg
  local levelID = self.m_levelCfg.m_LevelID
  self.m_isChoose = self.m_itemData.isChoose
  self.m_isUnlock, _, self.m_unlockStr = self.m_levelHelper:IsLevelUnLock(levelID)
  self.m_isPass = self.m_levelHelper:IsLevelHavePass(levelID)
  self:FreshItemUI()
  self:ChangeChoose(self.m_isChoose)
end

function UILamiaChallengeLevelItem:FreshItemUI()
  if not self.m_levelCfg then
    return
  end
  local levelCfg = self.m_levelCfg
  self.m_txt_challenge_name_Text.text = levelCfg.m_LevelRef
  self.m_txt_lock_name_Text.text = levelCfg.m_LevelRef
  UILuaHelper.SetActive(self.m_img_clear, self.m_isPass)
  UILuaHelper.SetActive(self.m_item_have_get, self.m_isPass)
  UILuaHelper.SetActive(self.m_img_lock, self.m_isUnlock ~= true)
  UILuaHelper.SetActive(self.m_node_normal, self.m_isUnlock == true)
  local keyWardItemData = levelCfg.m_KeyReward
  if keyWardItemData.Length == 0 then
    self.m_keyWardItemWidget:SetActive(false)
  else
    self.m_keyWardItemWidget:SetActive(true)
    local itemID = tonumber(keyWardItemData[0])
    local itemNum = tonumber(keyWardItemData[1])
    local processItemData = ResourceUtil:GetProcessRewardData({iID = itemID, iNum = itemNum})
    self.m_keyWardItemWidget:SetItemInfo(processItemData)
  end
end

function UILamiaChallengeLevelItem:ChangeChoose(isChoose)
  self.m_isChoose = isChoose
  self.m_itemData.isChoose = isChoose
  UILuaHelper.SetActive(self.m_frame_select, isChoose)
end

function UILamiaChallengeLevelItem:OnBtnChallengeClicked()
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

function UILamiaChallengeLevelItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return UILamiaChallengeLevelItem
