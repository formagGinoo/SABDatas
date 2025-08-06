local UISubPanelBase = require("UI/Common/UISubPanelBase")
local ActivityRebateSubPanel = class("ActivityRebateSubPanel", UISubPanelBase)

function ActivityRebateSubPanel:OnInit()
  self.m_itemListParent = self.m_item.transform.parent
  self.m_itemListCfg = nil
  self.m_ItemCache = {}
  self.sActivityCfg = {}
  self.sMessageList = {}
  self.stActivity = {}
end

function ActivityRebateSubPanel:OnFreshData()
  self:RefreshUI()
end

function ActivityRebateSubPanel:AddEventListeners()
end

function ActivityRebateSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function ActivityRebateSubPanel:RefreshUI()
  self.stActivity = self.m_panelData.activity
  self.sActivityCfg = self.stActivity.m_stSdpConfig.stClientCfg
  self.sMessageList = self.sActivityCfg.sMessage
  self.m_txt_tltle_Text.text = self.stActivity:getLangText(tostring(self.sActivityCfg.sTitle))
  self.m_txt_title_short:SetActive(false)
  self:InitItem()
end

function ActivityRebateSubPanel:InitItem()
  local childCount = self.m_itemListParent.childCount
  for i = 0, childCount - 1 do
    local child = self.m_itemListParent:GetChild(i)
    if child.gameObject.activeSelf then
      child.gameObject:SetActive(false)
    end
  end
  local elementCount = #self.sMessageList
  if childCount < elementCount then
    for index = childCount, elementCount - 1 do
      GameObject.Instantiate(self.m_item, self.m_itemListParent)
    end
  end
  for i, v in ipairs(self.sMessageList) do
    local child = self.m_itemListParent:GetChild(i - 1).gameObject
    child:SetActive(true)
    self:RefreshItemList(child, i - 1)
  end
end

function ActivityRebateSubPanel:RefreshItemList(go, index)
  local idx = index + 1
  local transform = go.transform
  local item = self.m_ItemCache[idx]
  local data = self.sMessageList[idx]
  if not item then
    item = {
      m_txt_item_title = transform:Find("pnl_title/img_titlebg/m_txt_item_title"):GetComponent(T_TextMeshProUGUI),
      m_textContent = transform:Find("m_textContent"):GetComponent(T_TextMeshProUGUI),
      pnl_title = transform:Find("pnl_title").gameObject
    }
    self.m_ItemCache[idx] = item
  end
  if tostring(data.sItemTitile) == "" then
    item.pnl_title:SetActive(false)
  end
  item.m_txt_item_title.text = self.stActivity:getLangText(tostring(data.sItemTitile))
  item.m_textContent.text = self.stActivity:getLangText(tostring(data.sDesc))
end

function ActivityRebateSubPanel:OnBtnshopClicked()
  StackFlow:Push(UIDefines.ID_FORM_MALLMAINNEW)
end

return ActivityRebateSubPanel
