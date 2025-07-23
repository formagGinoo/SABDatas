local UIItemBase = require("UI/Common/UIItemBase")
local UISettingQualityItem = class("UISettingQualityItem", UIItemBase)

function UISettingQualityItem:OnInit()
end

function UISettingQualityItem:OnFreshData()
  local itemData = self.m_itemData
  local qualityInfo = itemData.qualityInfo
  self.m_GraphicID = qualityInfo.m_GraphicID
  local qualityChoice = itemData.qualityChoice
  self.m_txt_title_pic_Text.text = qualityInfo.m_mSettingTitle
  self.m_txt_desc_pic_Text.text = qualityInfo.m_mSettingTip
  if self.m_widgetBtnFilter == nil then
    self.m_iMaxLevel = 1
    self.m_iSelectLevel = 1
    if self.m_GraphicID == 1 then
      self.m_iMaxLevel = CS.GameQualityManager.Instance.DetectedQualityLevel
      self.m_iSelectLevel = CS.GameQualityManager.Instance.CustomQualityLevel
    elseif self.m_GraphicID == 2 then
      self.m_iMaxLevel = CS.GameQualityManager.Instance:GetMaxFPS()
      self.m_iSelectLevel = self:GetFPSSetting()
    elseif self.m_GraphicID == 4 then
      self.m_iMaxLevel = 2
      self.m_iSelectLevel = self:GetAspectRatioSetting()
    end
    self.m_iCurSelectIndex = 1
    local vChoiceList = {}
    for i, v in ipairs(qualityChoice) do
      vChoiceList[#vChoiceList + 1] = {
        iIndex = i,
        sTitle = v.m_mSettingText
      }
      if self.m_GraphicID == 4 then
        print(v.m_GameValue, self.m_iSelectLevel, i)
      end
      if v.m_GameValue == self.m_iSelectLevel then
        self.m_iCurSelectIndex = i
      end
    end
    self.m_widgetBtnFilter = self:createFilterButton(self.m_ui_sys_fitler_pic)
    self.m_widgetBtnFilter:RefreshTabConfig(vChoiceList, self.m_iCurSelectIndex, nil, function(filterIndex, isFilterDown)
      if filterIndex == self.m_iCurSelectIndex then
        return
      end
      self:OnSelectChoice(filterIndex, qualityChoice[filterIndex].m_ChoiceID, qualityChoice[filterIndex].m_GameValue)
    end, function(item, tabConfig)
      local iGameValue = qualityChoice[tabConfig.iIndex].m_GameValue
      if tabConfig.iIndex == self.m_iCurSelectIndex then
        if iGameValue == self.m_iMaxLevel then
          item.transform:Find("txt_dis").gameObject:SetActive(false)
          item.transform:Find("txt_recommend").gameObject:SetActive(true)
          item.transform:Find("common_filter_tab_name").gameObject:SetActive(false)
          local itemText = item.transform:Find("txt_recommend"):Find("txt_rec"):GetComponent(T_TextMeshProUGUI)
          itemText.text = tabConfig.sTitle
          itemText.color = CS.UnityEngine.Color(0.2196078431372549, 0.2196078431372549, 0.2196078431372549)
        else
          item.transform:Find("txt_dis").gameObject:SetActive(false)
          item.transform:Find("txt_recommend").gameObject:SetActive(false)
          item.transform:Find("common_filter_tab_name").gameObject:SetActive(true)
          local itemText = item.transform:Find("common_filter_tab_name"):GetComponent(T_TextMeshProUGUI)
          itemText.text = tabConfig.sTitle
          itemText.color = CS.UnityEngine.Color(0.2196078431372549, 0.2196078431372549, 0.2196078431372549)
        end
        item.transform:Find("img_select_bg").gameObject:SetActive(true)
      else
        item.transform:Find("img_select_bg").gameObject:SetActive(false)
        if iGameValue > self.m_iMaxLevel then
          item.transform:Find("txt_dis").gameObject:SetActive(true)
          item.transform:Find("txt_recommend").gameObject:SetActive(false)
          item.transform:Find("common_filter_tab_name").gameObject:SetActive(false)
          item.transform:Find("txt_dis"):Find("txt_dis"):GetComponent(T_TextMeshProUGUI).text = tabConfig.sTitle
        elseif iGameValue == self.m_iMaxLevel then
          item.transform:Find("txt_dis").gameObject:SetActive(false)
          item.transform:Find("txt_recommend").gameObject:SetActive(true)
          item.transform:Find("common_filter_tab_name").gameObject:SetActive(false)
          local itemText = item.transform:Find("txt_recommend"):Find("txt_rec"):GetComponent(T_TextMeshProUGUI)
          itemText.text = tabConfig.sTitle
          itemText.color = CS.UnityEngine.Color(0.8588235294117647, 0.8235294117647058, 0.7411764705882353)
        else
          item.transform:Find("txt_dis").gameObject:SetActive(false)
          item.transform:Find("txt_recommend").gameObject:SetActive(false)
          item.transform:Find("common_filter_tab_name").gameObject:SetActive(true)
          local itemText = item.transform:Find("common_filter_tab_name"):GetComponent(T_TextMeshProUGUI)
          itemText.text = tabConfig.sTitle
          itemText.color = CS.UnityEngine.Color(0.8588235294117647, 0.8235294117647058, 0.7411764705882353)
        end
      end
      item.transform:Find("txt_contain").gameObject:SetActive(false)
    end, function(tabConfig)
      return tabConfig.sTitle
    end, function(filterTabList)
      UILuaHelper.ForceRebuildLayoutImmediate(filterTabList)
      local contentTrans = self.m_itemRootObj.transform.parent.gameObject:GetComponent(T_RectTransform)
      local viewPortTrans = self.m_itemRootObj.transform.parent.parent.gameObject:GetComponent(T_RectTransform)
      local scrollOffset = contentTrans.rect.height - viewPortTrans.rect.height
      local filterTabListTrans = filterTabList:GetComponent(T_RectTransform)
      local worldPos = filterTabListTrans:TransformPoint(filterTabListTrans.anchoredPosition3D)
      local localPos = viewPortTrans:InverseTransformPoint(worldPos)
      localPos.y = -(localPos.y - filterTabListTrans.rect.height)
      local maxY = viewPortTrans.rect.height
      if maxY < localPos.y then
        local offset = localPos.y - maxY
        local oldNormalizedPosition = self.m_itemData.scrollView:GetComponent("ScrollRect").normalizedPosition
        self.m_itemData.scrollView:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(oldNormalizedPosition.x, oldNormalizedPosition.y - offset / scrollOffset)
      end
    end, itemData.parentTransform)
  else
    self.m_widgetBtnFilter:OnBtnCloseClicked()
  end
end

function UISettingQualityItem:OnSelectChoice(iFilterIndex, iChoiceID, iValue)
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun()
  end
  if iValue > self.m_iMaxLevel then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40019)
    self.m_widgetBtnFilter:ForceChangeTabIndex(self.m_iCurSelectIndex)
    return
  end
  self.m_iCurSelectIndex = iFilterIndex
  if iChoiceID == 101 then
    CS.GameQualityManager.Instance.CustomQualityLevel = iValue
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 102 then
    CS.GameQualityManager.Instance.CustomQualityLevel = iValue
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 103 then
    CS.GameQualityManager.Instance.CustomQualityLevel = iValue
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 104 then
    CS.GameQualityManager.Instance.CustomQualityLevel = iValue
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 105 then
    CS.GameQualityManager.Instance.CustomQualityLevel = iValue
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 201 then
    CS.GameQualityManager.Instance:SetFPS(iValue)
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 202 then
    CS.GameQualityManager.Instance:SetFPS(iValue)
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 203 then
    CS.GameQualityManager.Instance:SetFPS(iValue)
    CS.GameQualityManager.Instance:ApplySettings()
    return
  elseif iChoiceID == 401 then
    if ChannelManager:IsWindows() then
      CS.FixedAspectRatioWindow.Instance():SetAspectRatio(1.7777777777777777)
    end
    return
  elseif iChoiceID == 402 then
    if ChannelManager:IsWindows() then
      CS.FixedAspectRatioWindow.Instance():SetAspectRatio(2.3333333333333335)
    end
    return
  end
end

function UISettingQualityItem:GetAspectRatioSetting()
  if ChannelManager:IsWindows() then
    local ratio = CS.UnityEngine.PlayerPrefs.GetFloat("AspectRatio", 2.3333333333333335)
    local targetRatio = 2.3333333333333335
    local epsilon = 0.001
    return epsilon > math.abs(ratio - targetRatio) and 0 or 1
  end
  return 1
end

function UISettingQualityItem:GetFPSSetting()
  return CS.UnityEngine.PlayerPrefs.GetInt("FPS_Index_Key", self.m_iMaxLevel)
end

function UISettingQualityItem:dispose()
  UISettingQualityItem.super.dispose(self)
end

return UISettingQualityItem
