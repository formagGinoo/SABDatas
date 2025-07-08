local Form_OptionalGift = class("Form_OptionalGift", require("UI/UIFrames/Form_OptionalGiftUI"))

function Form_OptionalGift:SetInitParam(param)
end

function Form_OptionalGift:AfterInit()
  local panelItem = self.m_pnl_gift.transform:Find("c_common_item").gameObject
  self.m_widgetItem = self:createCommonItem(panelItem)
  self.m_goPanelItemCustomTemplate = self.m_scrollViewItem:GetComponent("ScrollRect").content.transform:Find("pnl_item").gameObject
  self.m_goPanelItemCustomTemplate:SetActive(false)
  self.m_vPanelItemCustom = {}
end

function Form_OptionalGift:OnActive()
  local tParam = self.m_csui.m_param
  self.m_iID = tParam.iID
  self.m_iNumMax = ItemManager:GetItemNum(self.m_iID)
  self.m_mNumCustom = {}
  self.m_stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(self.m_iID)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = self.m_iID,
    iNum = 0
  })
  self.m_widgetItem:SetItemInfo(processData)
  self.m_txt_num01_Text.text = 0
  self.m_txt_num02_Text.text = self.m_iNumMax
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_num_list)
  self.m_txt_itemname_Text.text = tostring(processData.name)
  local panelItemCustomList = self.m_scrollViewItem:GetComponent("ScrollRect").content
  local v2PanelItemListOffset = panelItemCustomList:GetComponent("RectTransform").anchoredPosition
  v2PanelItemListOffset.x = 0
  panelItemCustomList:GetComponent("RectTransform").anchoredPosition = v2PanelItemListOffset
  local vGetItemInfo = string.split(self.m_stItemData.m_ItemUse, ";")
  for i = 1, #vGetItemInfo do
    local panelItemCustom = self.m_vPanelItemCustom[i]
    if panelItemCustom == nil then
      panelItemCustom = {}
      panelItemCustom.go = CS.UnityEngine.GameObject.Instantiate(self.m_goPanelItemCustomTemplate, panelItemCustomList)
      panelItemCustom.widgetItemIcon = self:createCommonItem(panelItemCustom.go.transform:Find("c_common_item").gameObject)
      panelItemCustom.widgetNumStepper = self:createNumStepper(panelItemCustom.go.transform:Find("ui_common_stepper").gameObject)
      panelItemCustom.widgetNumStepper:SetNumChangeCB(handler(self, self.OnNumStepperChange), i - 1)
      panelItemCustom.txtDesc = panelItemCustom.go.transform:Find("m_txt_desc"):GetComponent(T_TextMeshProUGUI)
      self.m_vPanelItemCustom[i] = panelItemCustom
    end
    panelItemCustom.go:SetActive(true)
    local vItemInfoStr = string.split(vGetItemInfo[i], ",")
    local iGetItemID = tonumber(vItemInfoStr[1])
    local iGetItemNum = tonumber(vItemInfoStr[2])
    local processData2 = ResourceUtil:GetProcessRewardData({iID = iGetItemID, iNum = iGetItemNum})
    panelItemCustom.widgetItemIcon:SetItemInfo(processData2)
    panelItemCustom.txtDesc.text = tostring(processData2.name)
    panelItemCustom.widgetNumStepper:SetNumMax(self.m_iNumMax)
    panelItemCustom.widgetNumStepper:SetNumMin(0)
    panelItemCustom.widgetNumStepper:SetNumCur(0)
  end
  for i = #vGetItemInfo + 1, #self.m_vPanelItemCustom do
    self.m_vPanelItemCustom[i].go:SetActive(false)
  end
  self:RefreshBtnState()
end

function Form_OptionalGift:OnNumStepperChange(iNumCur, iNumChange, sTag)
  self.m_mNumCustom[sTag] = iNumCur
  local iNumCustomTotal = 0
  for iIndex, iNum in pairs(self.m_mNumCustom) do
    iNumCustomTotal = iNumCustomTotal + iNum
  end
  self.m_txt_num01_Text.text = iNumCustomTotal
  self.m_txt_num02_Text.text = self.m_iNumMax
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_num_list)
  for i = 1, #self.m_vPanelItemCustom do
    local panelItemCustom = self.m_vPanelItemCustom[i]
    if panelItemCustom.go.activeSelf then
      local iNum = panelItemCustom.widgetNumStepper:GetNumCur()
      panelItemCustom.widgetNumStepper:SetNumMax(self.m_iNumMax - iNumCustomTotal + iNum)
      panelItemCustom.widgetNumStepper:SetNumMin(0)
      panelItemCustom.widgetNumStepper:SetNumCur(iNum)
    end
  end
  self:RefreshBtnState()
end

function Form_OptionalGift:RefreshBtnState()
  local iNumCustomTotal = 0
  for iIndex, iNum in pairs(self.m_mNumCustom) do
    iNumCustomTotal = iNumCustomTotal + iNum
  end
  self.m_btn_Confirm:SetActive(0 < iNumCustomTotal)
  self.m_btn_gray:SetActive(iNumCustomTotal == 0)
end

function Form_OptionalGift:OnBtnConfirmClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  local iNumCustomTotal = 0
  for iIndex, iNum in pairs(self.m_mNumCustom) do
    iNumCustomTotal = iNumCustomTotal + iNum
  end
  if iNumCustomTotal == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
    return
  end
  local stItemUseData = MTTDProto.ItemUseData()
  stItemUseData.mIndexIdNum = self.m_mNumCustom
  ItemManager:RequestItemUse(self.m_iID, iNumCustomTotal, stItemUseData)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_OPTIONALGIFT)
end

function Form_OptionalGift:OnBtngrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
end

function Form_OptionalGift:OnBtncancelClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_OPTIONALGIFT)
end

function Form_OptionalGift:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_OPTIONALGIFT)
end

function Form_OptionalGift:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_OptionalGift", Form_OptionalGift)
return Form_OptionalGift
