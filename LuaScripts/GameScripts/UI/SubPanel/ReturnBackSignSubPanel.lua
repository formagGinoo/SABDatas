local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ReturnBackSignSubPanel = class("ReturnBackSignSubPanel", UISubPanelBase)
local UIReturnBackSignItem = require("UI/Item/ReturnBackSignItem/UIReturnBackSignItem")

function ReturnBackSignSubPanel:OnInit()
  self:AddEventListeners()
  self.m_returnBackSignItemList = {}
  self.m_rewardItemDataList = nil
  UILuaHelper.SetActive(self.m_item, false)
end

function ReturnBackSignSubPanel:OnDestroy()
  ReturnBackSignSubPanel.super.OnDestroy(self)
  for i, v in ipairs(self.m_returnBackSignItemList) do
    if v then
      v:dispose()
    end
  end
  self.m_returnBackSignItemList = {}
end

function ReturnBackSignSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_ReturnBackSign_Reward", handler(self, self.OnGetSignReward))
  self:addEventListener("eGameEvent_Activity_Reload", handler(self, self.OnEventActivityReload))
end

function ReturnBackSignSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function ReturnBackSignSubPanel:OnFreshData()
  self:RefreshUI()
end

function ReturnBackSignSubPanel:OnGetSignReward(stParam)
  if stParam.iActivityId ~= self.m_stActivity:getID() then
    return
  end
  if self.m_rootObj.activeInHierarchy then
    utils.popUpRewardUI(stParam.vReward)
    self:RefreshReward()
    if self.m_parentLua then
      self.m_parentLua:RefreshTableButtonList()
    end
  end
end

function ReturnBackSignSubPanel:OnEventActivityReload()
  if self.m_rootObj.activeInHierarchy then
    self:RefreshUI()
  end
end

function ReturnBackSignSubPanel:InitSignItem(itemRoot, index)
  if not itemRoot then
    return
  end
  local initItemData = {
    itemClkBackFun = function(posIndex)
      self:OnItemGetRewardClk(posIndex)
    end
  }
  local tempRewardSignItem = UIReturnBackSignItem.new(nil, itemRoot, initItemData, nil, index)
  self.m_returnBackSignItemList[index] = tempRewardSignItem
  return tempRewardSignItem
end

function ReturnBackSignSubPanel:RefreshUI()
  local activityId = self.m_panelData.activity:getID()
  self.m_stActivity = ActivityManager:GetActivityByID(activityId)
  if not self.m_stActivity then
    return
  end
  self:RefreshReward()
  self:RefreshRemainTime()
end

function ReturnBackSignSubPanel:RefreshReward()
  if not self.m_stActivity then
    return
  end
  self.m_rewardItemDataList = self.m_stActivity:GetReturnBackSignRewardList()
  self:FreshRewardItems()
end

function ReturnBackSignSubPanel:FreshRewardItems()
  if not self.m_rewardItemDataList then
    return
  end
  local itemNodes = self.m_returnBackSignItemList
  local dataLen = #self.m_rewardItemDataList
  local parentTrans = self.m_pnl_item_root.transform
  local childCount = #itemNodes
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemNode = itemNodes[i]
      self:FreshItemNodeShow(itemNode, self.m_rewardItemDataList[i])
      itemNode:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_item, parentTrans).gameObject
      itemObj.name = i
      local itemNode = self:InitSignItem(itemObj, i)
      local itemData = self.m_rewardItemDataList[i]
      self:FreshItemNodeShow(itemNode, itemData)
      itemNode:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemNodes[i]:SetActive(false)
    end
  end
end

function ReturnBackSignSubPanel:FreshItemNodeShow(returnBackSignItem, itemData)
  if not returnBackSignItem then
    return
  end
  returnBackSignItem:FreshItemShow(itemData)
end

function ReturnBackSignSubPanel:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  self:killRemainTimer()
  self.endTime = self.m_stActivity:getActivityEndTime()
  if self.endTime == 0 then
    self.m_PanelRemainTime:SetActive(false)
    return
  end
  self.m_PanelRemainTime:SetActive(true)
  local remainTime = 0 < self.endTime - TimeUtil:GetServerTimeS() and self.endTime - TimeUtil:GetServerTimeS() or 0
  if not remainTime or remainTime <= 0 then
    StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
    return
  end
  local showStr = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
  showStr = string.CS_Format(ConfigManager:GetCommonTextById(220018), showStr)
  self.m_txtRemainTime_Text.text = showStr
  self.remainTimer = TimeService:SetTimer(1, -1, function()
    remainTime = self.endTime - TimeUtil:GetServerTimeS() > 0 and self.endTime - TimeUtil:GetServerTimeS() or 0
    local tempShowStr = TimeUtil:SecondsToFormatStrDHOrHMS(remainTime)
    self.m_txtRemainTime_Text.text = string.CS_Format(ConfigManager:GetCommonTextById(220018), tempShowStr)
    if remainTime <= 0 then
      self:killRemainTimer()
      self:SetActive(false)
      StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
    end
  end)
end

function ReturnBackSignSubPanel:killRemainTimer()
  if self.remainTimer then
    TimeService:KillTimer(self.remainTimer)
    self.remainTimer = nil
  end
end

function ReturnBackSignSubPanel:OnInactivePanel()
  self:killRemainTimer()
end

function ReturnBackSignSubPanel:OnItemGetRewardClk(itemIndex)
  if not itemIndex then
    return
  end
  if not self.m_stActivity then
    return
  end
  self.m_stActivity:ReqActReturnSignGetSignReward()
end

return ReturnBackSignSubPanel
