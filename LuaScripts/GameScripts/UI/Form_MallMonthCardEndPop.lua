local Form_MallMonthCardEndPop = class("Form_MallMonthCardEndPop", require("UI/UIFrames/Form_MallMonthCardEndPopUI"))
local StoreMonthlyPrivilegesIns = ConfigManager:GetConfigInsByName("StoreMonthlyPrivileges")
local privateTips = ConfigManager:GetCommonTextById(220026)

function Form_MallMonthCardEndPop:SetInitParam(param)
end

function Form_MallMonthCardEndPop:AfterInit()
  self.super.AfterInit(self)
  self.m_privilegeScrollViewItemsTemplate = self.m_scrollView:GetComponent("ScrollRect").content.transform:Find("cell_0").gameObject
  self.m_content = self.m_scrollView:GetComponent("ScrollRect").content
  self.m_privilegeScrollViewItemsTemplate:SetActive(false)
  self.m_vPrivilegeScrollViewItems = {}
  self.m_privilegeList = self:LoadPrivilegeList()
end

function Form_MallMonthCardEndPop:LoadPrivilegeList()
  local privileges = StoreMonthlyPrivilegesIns:GetAll()
  local privilegeList = {}
  for _, privilege in pairs(privileges) do
    if not privilege:GetError() then
      table.insert(privilegeList, {cfg = privilege})
    end
  end
  return privilegeList
end

function Form_MallMonthCardEndPop:OnActive()
  self.super.OnActive(self)
  self:ResetScrollViewPosition()
  self:RefreshPrivilegeItems()
end

function Form_MallMonthCardEndPop:ResetScrollViewPosition()
  local panelItemList = self.m_content
  local panelRectTransform = panelItemList:GetComponent("RectTransform")
  local offset = panelRectTransform.anchoredPosition
  offset.y = 0
  panelRectTransform.anchoredPosition = offset
end

function Form_MallMonthCardEndPop:RefreshPrivilegeItems()
  local panelItemList = self.m_content
  for i, privilegeData in ipairs(self.m_privilegeList) do
    local privilegeCfg = privilegeData.cfg
    local panelItem = self.m_vPrivilegeScrollViewItems[i]
    if not panelItem then
      panelItem = {}
      panelItem.go = CS.UnityEngine.GameObject.Instantiate(self.m_privilegeScrollViewItemsTemplate, panelItemList)
      self.m_vPrivilegeScrollViewItems[i] = panelItem
    end
    panelItem.go:SetActive(true)
    self:SetupPrivilegeItem(panelItem.go, privilegeCfg, i == 1)
  end
  for i = #self.m_privilegeList + 1, #self.m_vPrivilegeScrollViewItems do
    self.m_vPrivilegeScrollViewItems[i].go:SetActive(false)
  end
end

function Form_MallMonthCardEndPop:SetupPrivilegeItem(goItem, privilegeCfg, isFirstItem)
  if isFirstItem then
    goItem.transform:Find("m_bg_txt/m_txt_name_info").gameObject:GetComponent("TMPPro").text = privateTips
  end
  goItem.transform:Find("m_bg_txt").gameObject:SetActive(isFirstItem)
  goItem.transform:Find("pnl_info/m_txt_info").gameObject:GetComponent("TMPPro").text = privilegeCfg.m_mEffectDes
  local isUnlock = MonthlyCardManager:IsPrivilegeEffect()
  local btn = goItem.transform:Find("pnl_info/m_btn_go").gameObject:GetComponent("Button")
  if isUnlock then
    UILuaHelper.BindButtonClickManual(self, btn, function()
      QuickOpenFuncUtil:OpenFunc(privilegeCfg.m_Jump)
      StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_MALLMONTHCARDENDPOP)
    end)
  end
  UILuaHelper.SetActive(btn.gameObject, isUnlock)
  local imageComponent = goItem.transform:Find("pnl_info/img_bgicon/m_icon_info").gameObject:GetComponent("Image")
  UILuaHelper.SetAtlasSprite(imageComponent, privilegeCfg.m_Icon)
end

function Form_MallMonthCardEndPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_MallMonthCardEndPop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_MallMonthCardEndPop", Form_MallMonthCardEndPop)
return Form_MallMonthCardEndPop
