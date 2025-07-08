local FilterButton = class("FilterButton")
local CanScrollNum = 5
local scroll_pos = Vector2.New(0, 0)
local ItemHeight = 80

function FilterButton:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_goRootTrans = self.m_goRoot.transform
  self.m_goFilterTabCur = self.m_goRoot.transform:Find("btn").gameObject
  UILuaHelper.BindButtonClickManual(self, self.m_goFilterTabCur:GetComponent("Button"), handler(self, self.OnBtnFilterTabCurClicked))
  self.m_textFilterCur = self.m_goFilterTabCur.transform:Find("common_filter_txt_name"):GetComponent(T_TextMeshProUGUI)
  self.m_bShowFilterTabList = false
  local temp = self.m_goFilterTabCur.transform:Find("list_bg") or self.m_goFilterTabCur.transform:Find("scroll/view/list_bg")
  self.m_goFilterTabList = temp.gameObject
  self.m_oldParent = self.m_goRoot.transform.parent
  self.m_oldLocalPos = self.m_goRoot.transform.localPosition
  self.m_goFilterTabTemplate = self.m_goFilterTabList.transform:Find("btn_tab").gameObject
  self.m_goFilterTabTemplate:SetActive(false)
  self.m_goFilterTab = {}
  if self.m_goFilterTabCur.transform:Find("btn_updown") then
    self.m_goUpDownBtn = self.m_goFilterTabCur.transform:Find("btn_updown").gameObject
    UILuaHelper.BindButtonClickManual(self, self.m_goUpDownBtn:GetComponent("Button"), handler(self, self.OnBtnupdownClicked))
  end
  local scroll = self.m_goFilterTabCur.transform:Find("scroll")
  if scroll then
    self.m_scroll_obj = scroll.gameObject
    self.m_scroll_rect = scroll:GetComponent("ScrollRect")
    self.m_view_layoutele = scroll:Find("view"):GetComponent("LayoutElement")
  end
  self.m_btn_close = self.m_goRoot.transform:Find("btn_close"):GetComponent(T_Button)
  self.m_btn_close.onClick:RemoveAllListeners()
  UILuaHelper.BindButtonClickManual(self, self.m_btn_close, handler(self, self.OnBtnCloseClicked))
end

function FilterButton:RefreshTabConfig(vTabConfig, iIndexCur, bFilterDown, fChangeCB, fBindCB, fBindSelectCB, fOpenCB, parentTransform)
  self.m_vTabConfig = vTabConfig
  self.m_fChangeCB = fChangeCB
  self.m_fBindCB = fBindCB
  self.m_fBindSelectCB = fBindSelectCB
  self.m_fOpenCB = fOpenCB
  self.m_parentTransform = parentTransform
  self.m_iIndexCur = iIndexCur or 1
  self:RefreshFilterBtnCur()
  self.m_bShowFilterTabList = false
  self.m_goFilterTabList:SetActive(false)
  UILuaHelper.SetActive(self.m_btn_close, false)
  self:InitScroll()
  self.m_bFilterDown = bFilterDown
  self:RefreshFilterupDown()
end

function FilterButton:OnUpdate(dt)
end

function FilterButton:RefreshFilterBtnCur()
  for _, stTagConfig in ipairs(self.m_vTabConfig) do
    if stTagConfig.iIndex == self.m_iIndexCur then
      if self.m_fBindSelectCB then
        self.m_textFilterCur.text = self.m_fBindSelectCB(stTagConfig)
        break
      end
      self.m_textFilterCur.text = ConfigManager:GetCommonTextById(stTagConfig.sTitle)
      break
    end
  end
end

function FilterButton:OnBtnFilterTabCurClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_bShowFilterTabList = not self.m_bShowFilterTabList
  self:RefreshFilterList()
  if self.m_fOpenCB then
    self.m_fOpenCB(self.m_goFilterTabList)
  end
  if self.m_parentTransform and self.m_bShowFilterTabList then
    local rootTrans = self.m_goRootTrans
    local worldPos = rootTrans.parent:TransformPoint(rootTrans.localPosition)
    local localPos = self.m_parentTransform:InverseTransformPoint(worldPos)
    rootTrans:SetParent(self.m_parentTransform)
    rootTrans.localPosition = localPos
  end
  if self.m_scroll_rect and self.m_bShowFilterTabList then
    if #self.m_vTabConfig > CanScrollNum then
      self.m_scroll_rect.vertical = true
      TimeService:SetTimer(0.05, 1, function()
        local temp = #self.m_vTabConfig - self.m_iIndexCur + 1
        scroll_pos.x = self.m_scroll_rect.content.anchoredPosition.x
        scroll_pos.y = -temp * ItemHeight
        self.m_scroll_rect.content.anchoredPosition = scroll_pos
      end)
    else
      self.m_scroll_rect.vertical = false
    end
  end
end

function FilterButton:RefreshFilterList()
  self.m_goFilterTabList:SetActive(self.m_bShowFilterTabList)
  if self.m_scroll_obj then
    self.m_scroll_obj:SetActive(self.m_bShowFilterTabList)
  end
  UILuaHelper.SetActive(self.m_btn_close, self.m_bShowFilterTabList)
  if self.m_bShowFilterTabList then
    local iCount = 0
    for _, stTabConfig in ipairs(self.m_vTabConfig) do
      iCount = iCount + 1
      local goFilterTab = self.m_goFilterTab[iCount]
      if goFilterTab == nil then
        goFilterTab = CS.UnityEngine.GameObject.Instantiate(self.m_goFilterTabTemplate, self.m_goFilterTabList.transform)
        goFilterTab:SetActive(true)
        self.m_goFilterTab[iCount] = goFilterTab
      end
      goFilterTab:GetComponent("Button").onClick:RemoveAllListeners()
      UILuaHelper.BindButtonClickManual(self, goFilterTab:GetComponent("Button"), function()
        self:OnBtnFilterTabClicked(stTabConfig.iIndex)
      end)
      local selectedObj = goFilterTab.transform:Find("c_img_seleted")
      if self.m_fBindCB then
        self.m_fBindCB(goFilterTab, stTabConfig)
      else
        goFilterTab.transform:Find("common_filter_tab_name"):GetComponent(T_TextMeshProUGUI).text = ConfigManager:GetCommonTextById(stTabConfig.sTitle)
        if not utils.isNull(selectedObj) then
          local selectedText = selectedObj.transform:Find("c_txt_selected"):GetComponent(T_TextMeshProUGUI)
          selectedText.text = ConfigManager:GetCommonTextById(stTabConfig.sTitle)
        end
      end
      if not utils.isNull(selectedObj) then
        selectedObj.gameObject:SetActive(stTabConfig.iIndex == self.m_iIndexCur)
      end
    end
    for i = iCount + 1, #self.m_goFilterTab do
      self.m_goFilterTab[i]:SetActive(false)
    end
  elseif self.m_parentTransform then
    self.m_goRootTrans:SetParent(self.m_oldParent)
    self.m_goRootTrans.localPosition = self.m_oldLocalPos
  end
end

function FilterButton:ForceChangeTabIndex(iFilterIndex)
  self.m_iIndexCur = iFilterIndex
  self:RefreshFilterBtnCur()
end

function FilterButton:OnBtnFilterTabClicked(iIndex)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_iIndexCur = iIndex
  self:RefreshFilterBtnCur()
  self.m_bShowFilterTabList = false
  self:RefreshFilterList()
  if self.m_fChangeCB then
    self.m_fChangeCB(self.m_iIndexCur, self.m_bFilterDown, self.m_vTabConfig[self.m_iIndexCur])
  end
end

function FilterButton:OnBtnCloseClicked()
  if self.m_bShowFilterTabList then
    self.m_bShowFilterTabList = false
    self:RefreshFilterList()
  end
end

function FilterButton:RefreshFilterupDown()
  if self.m_goUpDownBtn then
    if self.m_bFilterDown then
      if self.m_goUpDownBtn.transform:Find("icon_downselect") then
        UILuaHelper.SetActive(self.m_goUpDownBtn.transform:Find("icon_downselect").gameObject, true)
      end
      if self.m_goUpDownBtn.transform:Find("icon_upselect") then
        UILuaHelper.SetActive(self.m_goUpDownBtn.transform:Find("icon_upselect").gameObject, false)
      end
    else
      if self.m_goUpDownBtn.transform:Find("icon_downselect") then
        UILuaHelper.SetActive(self.m_goUpDownBtn.transform:Find("icon_downselect").gameObject, false)
      end
      if self.m_goUpDownBtn.transform:Find("icon_upselect") then
        UILuaHelper.SetActive(self.m_goUpDownBtn.transform:Find("icon_upselect").gameObject, true)
      end
    end
  end
end

function FilterButton:OnBtnupdownClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self.m_bFilterDown = not self.m_bFilterDown
  self:RefreshFilterupDown()
  if self.m_goDownIcon then
    UILuaHelper.SetActive(self.m_goDownIcon, false)
  end
  if self.m_fChangeCB then
    self.m_fChangeCB(self.m_iIndexCur, self.m_bFilterDown, self.m_vTabConfig[self.m_iIndexCur])
  end
end

function FilterButton:InitScroll()
  if self.m_view_layoutele then
    local is_add_offset = #self.m_vTabConfig > CanScrollNum
    self.m_view_layoutele.preferredHeight = is_add_offset and CanScrollNum * ItemHeight + ItemHeight / 2 or #self.m_vTabConfig * ItemHeight
    self.m_scroll_obj:SetActive(false)
  end
end

function FilterButton:OnDestroy()
end

return FilterButton
