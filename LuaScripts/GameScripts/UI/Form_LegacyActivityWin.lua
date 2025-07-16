local Form_LegacyActivityWin = class("Form_LegacyActivityWin", require("UI/UIFrames/Form_LegacyActivityWinUI"))
local DurationTime = 0.1
local ItemInAnimStr = "BattleVictory_common_item_in"

function Form_LegacyActivityWin:SetInitParam(param)
end

function Form_LegacyActivityWin:AfterInit()
  self.super.AfterInit(self)
  self.m_itemDataList = nil
  self.m_ItemWidgetList = {}
  self.m_rewardItemBase = self.m_list_item.transform:Find("c_common_item")
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
end

function Form_LegacyActivityWin:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(184)
  self:FreshData()
  self:FreshUI()
end

function Form_LegacyActivityWin:OnInactive()
  self.super.OnInactive(self)
  self:ClearData()
end

function Form_LegacyActivityWin:OnDestroy()
  self.super.OnDestroy(self)
  self:ClearData()
end

function Form_LegacyActivityWin:AddEventListeners()
end

function Form_LegacyActivityWin:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LegacyActivityWin:ClearData()
end

function Form_LegacyActivityWin:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelID = tParam.levelID
  self.m_csRewardList = tParam.rewardData
  self:FreshRewardListData()
  self.m_csui.m_param = nil
end

function Form_LegacyActivityWin:FreshRewardListData()
  if not self.m_csRewardList then
    return
  end
  self.m_itemDataList = {}
  for _, rewardCsData in pairs(self.m_csRewardList) do
    if rewardCsData then
      local tempReward = {
        iID = rewardCsData.iID,
        iNum = rewardCsData.iNum
      }
      self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
    end
  end
end

function Form_LegacyActivityWin:FreshUI()
  if self.m_levelType == nil or self.m_levelType == 0 then
    return
  end
  self:FreshRewardItems()
end

function Form_LegacyActivityWin:FreshRewardItems()
  if not self.m_itemDataList then
    return
  end
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = #self.m_itemDataList
  local parentTrans = self.m_list_item
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local processItemData = ResourceUtil:GetProcessRewardData(self.m_itemDataList[i])
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans.transform).gameObject
      local itemWidget = self:createCommonItem(itemObj)
      local processItemData = ResourceUtil:GetProcessRewardData(self.m_itemDataList[i])
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function Form_LegacyActivityWin:OnRewardItemClick(itemID, itemNum, itemCom)
  if self.m_isShowAnim then
    return
  end
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_LegacyActivityWin:OnBtnBgCloseClicked()
end

function Form_LegacyActivityWin:OnBtnyesClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_LegacyActivityWin:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LegacyActivityWin", Form_LegacyActivityWin)
return Form_LegacyActivityWin
