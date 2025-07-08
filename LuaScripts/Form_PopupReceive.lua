local Form_PopupReceive = class("Form_PopupReceive", require("UI/UIFrames/Form_PopupReceiveUI"))
local IntervalNum = 5

function Form_PopupReceive:SetInitParam(param)
end

function Form_PopupReceive:AfterInit()
  self.m_goPanelItemBigTemplate = self.m_scrollViewItem:GetComponent("ScrollRect").content.transform:Find("c_common_item").gameObject
  self.m_goPanelItemBigTemplate:SetActive(false)
  self.m_vPanelItemBig = {}
  self.m_updateQueueItemBig = self:addComponent("UpdateQueue", IntervalNum)
end

function Form_PopupReceive:OnActive()
  local tParam = self.m_csui.m_param
  self.m_closeCallBack = tParam.closeCallBack
  self.m_updateQueueItemBig:clear()
  self.m_vItem = tParam.vItem
  self:RefreshItemList()
  GlobalManagerIns:TriggerWwiseBGMState(40)
  self:AddEventListeners()
end

function Form_PopupReceive:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  for i, _ in ipairs(self.m_vItem) do
    if self["ItemTimer" .. i] then
      TimeService:KillTimer(self["ItemTimer" .. i])
      self["ItemTimer" .. i] = nil
    end
    if self["ItemTimerNext" .. i] then
      TimeService:KillTimer(self["ItemTimerNext" .. i])
      self["ItemTimerNext" .. i] = nil
    end
  end
end

function Form_PopupReceive:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnItemJumpClose))
end

function Form_PopupReceive:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PopupReceive:RefreshItemList()
  local panelItemList = self.m_scrollViewItem:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.y = 0
  panelItemList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  for i = 1, #self.m_vPanelItemBig do
    self.m_vPanelItemBig[i].go:SetActive(false)
  end
  if self.m_vItem and 0 < #self.m_vItem then
    for i, _ in ipairs(self.m_vItem) do
      if self["ItemTimer" .. i] then
        TimeService:KillTimer(self["ItemTimer" .. i])
        self["ItemTimer" .. i] = nil
      end
      if self["ItemTimerNext" .. i] then
        TimeService:KillTimer(self["ItemTimerNext" .. i])
        self["ItemTimerNext" .. i] = nil
      end
      local iIndex = i
      self.m_updateQueueItemBig:addWait(function()
        local goPanelItemBig = self.m_vPanelItemBig[iIndex]
        if goPanelItemBig == nil then
          goPanelItemBig = {}
          goPanelItemBig.go = CS.UnityEngine.GameObject.Instantiate(self.m_goPanelItemBigTemplate, panelItemList)
          goPanelItemBig.widget = self:createCommonItem(goPanelItemBig.go)
          self.m_vPanelItemBig[iIndex] = goPanelItemBig
        end
        goPanelItemBig.go:SetActive(true)
        local stItemInfo = self.m_vItem[iIndex]
        local processData = ResourceUtil:GetProcessRewardData({
          iID = stItemInfo.iID,
          iNum = stItemInfo.iNum
        })
        goPanelItemBig.widget:SetItemInfo(processData)
        goPanelItemBig.widget:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
        if goPanelItemBig.go.transform:Find("m_fx_switch") then
          local obj = goPanelItemBig.go.transform:Find("m_fx_switch").gameObject
          local obj2
          if goPanelItemBig.go.transform:Find("c_icon_hero_transform") then
            obj2 = goPanelItemBig.go.transform:Find("c_icon_hero_transform").gameObject
          end
          if stItemInfo.isRepeat then
            CS.GlobalManager.Instance:TriggerWwiseBGMState(237)
            UILuaHelper.SetActive(obj, true)
            if obj2 then
              self["ItemTimer" .. i] = TimeService:SetTimer(1, 1, function()
                UILuaHelper.SetActive(obj2, true)
                self["ItemTimerNext" .. i] = TimeService:SetTimer(0.5, 1, function()
                  local tempprocessData = ResourceUtil:GetProcessRewardData({
                    iID = stItemInfo.isTrunId,
                    iNum = stItemInfo.isTrunNum
                  })
                  goPanelItemBig.widget:SetItemInfo(tempprocessData)
                  goPanelItemBig.widget:SetItemIconClickCB(handler(self, self.OnItemIconClicked))
                end)
              end)
            end
          else
            UILuaHelper.SetActive(obj, false)
            if obj2 then
              UILuaHelper.SetActive(obj2, false)
            end
          end
        end
        return true
      end)
    end
  end
end

function Form_PopupReceive:OnItemIconClicked(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function Form_PopupReceive:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_POPUPRECEIVE)
  PushFaceManager:CheckShowNextPopRewardPanel()
  if self.m_closeCallBack then
    self.m_closeCallBack()
  end
end

function Form_PopupReceive:OnItemJumpClose()
  self:CloseForm()
  PushFaceManager:CheckShowNextPopRewardPanel()
end

function Form_PopupReceive:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PopupReceive", Form_PopupReceive)
return Form_PopupReceive
