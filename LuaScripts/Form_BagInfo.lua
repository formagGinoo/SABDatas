local Form_BagInfo = class("Form_BagInfo", require("UI/UIFrames/Form_BagInfoUI"))
local RarityStr = {
  [1] = 1001,
  [2] = 1002,
  [3] = 1003,
  [4] = 1004
}

function Form_BagInfo:SetInitParam(param)
end

function Form_BagInfo:AfterInit()
  self.m_goPanelProbabilityItemsTemplate = self.m_scrollView:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  self.m_goPanelProbabilityItemsTemplate:SetActive(false)
  self.m_vPanelProbabilityItems = {}
  self.m_goPanelItemTemplate = self.m_goPanelProbabilityItemsTemplate.transform:Find("pnl_bg/pnl_item").gameObject
  self.m_goPanelItemTemplate:SetActive(false)
  self.m_vPanelItem = {}
end

function Form_BagInfo:OnActive()
  local tParam = self.m_csui.m_param
  self.m_iRandomPoolID = tParam.iRandomPoolID
  self.m_stRandomPoolData = ConfigManager:GetConfigInsByName("Randompool"):GetValue_ByRandompoolID(self.m_iRandomPoolID)
  if self.m_stRandomPoolData == nil then
    return
  end
  local panelItemList = self.m_scrollView:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local iWeightTotal = 0
  local mWeight = {}
  local mItemInfo = {}
  local vRandomItemInfo = utils.changeCSArrayToLuaTable(self.m_stRandomPoolData.m_RandompoolContent)
  if ActivityManager:IsInCensorOpen() then
    local temp = utils.changeCSArrayToLuaTable(self.m_stRandomPoolData.m_CensorRandompoolContent)
    vRandomItemInfo = 0 < #temp and temp or vRandomItemInfo
  end
  for i = 1, #vRandomItemInfo do
    local vItemInfoStr = vRandomItemInfo[i]
    local iGetItemID = tonumber(vItemInfoStr[1])
    local iGetItemNum = tonumber(vItemInfoStr[2])
    local iWeight = tonumber(vItemInfoStr[3])
    iWeightTotal = iWeightTotal + iWeight
    local stItemInfo = {
      iID = iGetItemID,
      iNum = iGetItemNum,
      iWeight = iWeight
    }
    local stItemData = ResourceUtil:GetProcessRewardData(stItemInfo)
    if mWeight[stItemData.quality] == nil then
      mWeight[stItemData.quality] = 0
    end
    mWeight[stItemData.quality] = mWeight[stItemData.quality] + iWeight
    if mItemInfo[stItemData.quality] == nil then
      mItemInfo[stItemData.quality] = {}
    end
    table.insert(mItemInfo[stItemData.quality], stItemInfo)
  end
  local iCount = 0
  local iItemIcount = 0
  for i = 4, 1, -1 do
    local vItemInfo = mItemInfo[i]
    if vItemInfo and 0 < #vItemInfo then
      iCount = iCount + 1
      local panelProbabilityItemInfo = self.m_vPanelProbabilityItems[iCount]
      if panelProbabilityItemInfo == nil then
        panelProbabilityItemInfo = {}
        panelProbabilityItemInfo.go = CS.UnityEngine.GameObject.Instantiate(self.m_goPanelProbabilityItemsTemplate, panelItemList)
        self.m_vPanelProbabilityItems[iCount] = panelProbabilityItemInfo
      end
      local goProbabilityItemInfo = panelProbabilityItemInfo.go
      goProbabilityItemInfo:SetActive(true)
      local textRarity = goProbabilityItemInfo.transform:Find("bg_tab02/txt_baginfo_name01"):GetComponent(T_TextMeshProUGUI)
      textRarity.text = ConfigManager:GetCommonTextById(RarityStr[i])
      local textProbability = goProbabilityItemInfo.transform:Find("bg_tab02/txt_baginfo_name02"):GetComponent(T_TextMeshProUGUI)
      textProbability.text = string.format("%.2f", mWeight[i] / iWeightTotal * 100) .. "%"
      local panelItemContent = goProbabilityItemInfo.transform:Find("pnl_bg")
      for j = 1, #vItemInfo do
        iItemIcount = iItemIcount + 1
        local stItemInfo = vItemInfo[j]
        local panelItem = self.m_vPanelItem[iItemIcount]
        if panelItem == nil then
          panelItem = {}
          panelItem.go = CS.UnityEngine.GameObject.Instantiate(self.m_goPanelItemTemplate, panelItemContent)
          panelItem.widgetItemIcon = self:createCommonItem(panelItem.go.transform:Find("c_common_item").gameObject)
          self.m_vPanelItem[iItemIcount] = panelItem
        else
          panelItem.go.transform:SetParent(panelItemContent)
        end
        panelItem.go:SetActive(true)
        local processData = ResourceUtil:GetProcessRewardData({
          iID = stItemInfo.iID,
          iNum = stItemInfo.iNum
        })
        panelItem.widgetItemIcon:SetItemInfo(processData)
        local stItemData = ResourceUtil:GetProcessRewardData(stItemInfo)
        panelItem.go.transform:Find("txt_item_name"):GetComponent(T_TextMeshProUGUI).text = stItemData.name
        panelItem.go.transform:Find("txt_baginfo_name"):GetComponent(T_TextMeshProUGUI).text = string.format("%.2f", stItemInfo.iWeight / iWeightTotal * 100) .. "%"
      end
      CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(panelItemContent:GetComponent("RectTransform"))
      local sizeDelta = goProbabilityItemInfo:GetComponent("RectTransform").sizeDelta
      sizeDelta.y = panelItemContent:GetComponent("RectTransform").sizeDelta.y + 80
      goProbabilityItemInfo:GetComponent("RectTransform").sizeDelta = sizeDelta
    end
  end
  for i = iCount + 1, #self.m_vPanelProbabilityItems do
    self.m_vPanelProbabilityItems[i].go:SetActive(false)
  end
  for i = iItemIcount + 1, #self.m_vPanelItem do
    self.m_vPanelItem[i].go:SetActive(false)
  end
end

function Form_BagInfo:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_BAGINFO)
end

function Form_BagInfo:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BagInfo", Form_BagInfo)
return Form_BagInfo
