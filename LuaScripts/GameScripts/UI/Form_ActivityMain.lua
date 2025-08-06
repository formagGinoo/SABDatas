local Form_ActivityMain = class("Form_ActivityMain", require("UI/UIFrames/Form_ActivityMainUI"))

function Form_ActivityMain:SetInitParam(param)
end

function Form_ActivityMain:AfterInit()
  self.super.AfterInit(self)
  self.m_TabItemCache = {}
  self.m_subPanelData = {}
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_btn_symbol:SetActive(false)
  self.m_curType = nil
end

function Form_ActivityMain:OnActive()
  self:addEventListener("eGameEvent_Activity_ResetData", handler(self, self.OnActivityResetData))
  self:RefreshActivityList()
  local param = self.m_csui.m_param
  local selectIndex
  self.subPanelTabIndex = nil
  if param ~= nil then
    selectIndex = self:GetSelecteIndex(param.activityId)
    self.m_csui.m_param = nil
    if param.cliveType then
      self.subPanelTabIndex = param.cliveType
    end
  end
  selectIndex = selectIndex or self.m_selectIndex or 1
  self.m_selectIndex = nil
  self:OnSelectIndex(selectIndex)
end

function Form_ActivityMain:OnActivityResetData()
  self:RefreshActivityList()
  local selectIndex = self.m_selectIndex or 1
  if selectIndex > #self.m_vActivityList then
    selectIndex = 1
  end
  self:OnSelectIndex(selectIndex)
end

function Form_ActivityMain:GetSelecteIndex(param)
  for i, v in ipairs(self.m_vActivityList) do
    if v:getID() == param then
      return i
    end
  end
end

function Form_ActivityMain:ChooseActivityByID(iActivityID)
  for i, v in ipairs(self.m_vActivityList) do
    if v:getID() == iActivityID then
      self:OnSelectIndex(i)
      break
    end
  end
end

function Form_ActivityMain:GetActivitySubPanel(iActivityID)
  for i, v in ipairs(self.m_subPanelData) do
    if i == iActivityID then
      return v
    end
  end
end

function Form_ActivityMain:RefreshTableButtonList()
  local panelRoot = self.m_tabItem.transform.parent
  local childCount = panelRoot.childCount
  for i = 0, childCount - 1 do
    local child = panelRoot:GetChild(i)
    if child.gameObject.activeSelf then
      child.gameObject:SetActive(false)
    end
  end
  local elementCount = #self.m_vActivityList
  if childCount <= elementCount then
    for index = childCount, elementCount do
      GameObject.Instantiate(self.m_tabItem, panelRoot)
    end
  end
  for i, v in ipairs(self.m_vActivityList) do
    local child = panelRoot:GetChild(i - 1).gameObject
    child:SetActive(true)
    self:OnInitTabItem(child, i)
  end
  self:RefreshRedDot()
end

function Form_ActivityMain:OnInitTabItem(go, index)
  local item = self.m_TabItemCache[index]
  local transform = go.transform
  if not item then
    item = {
      m_tab_select = transform:Find("m_select").gameObject,
      m_tab_unselect = transform:Find("m_unselect").gameObject,
      m_img_RedDot = transform:Find("m_red"),
      m_text_selected = transform:Find("m_select/m_txt_select"):GetComponent(T_TextMeshProUGUI),
      m_text_unselected = transform:Find("m_unselect/m_txt_unselect"):GetComponent(T_TextMeshProUGUI)
    }
    local img = transform:Find("m_select/m_img_icon_select")
    if img then
      img.gameObject:SetActive(false)
    end
    img = transform:Find("m_unselect/m_img_icon_unselect")
    if img then
      img.gameObject:SetActive(false)
    end
    local btn = transform:GetComponent(T_Button)
    btn.onClick:AddListener(function()
      self:OnSelectIndex(index)
    end)
    self.m_TabItemCache[index] = item
  end
  local activity = self.m_vActivityList[index]
  local title = activity:getLangText(activity:getTitle())
  item.m_text_selected.text = title
  item.m_text_unselected.text = title
end

function Form_ActivityMain:RefreshRedDot()
  for i, v in ipairs(self.m_vActivityList) do
    local item = self.m_TabItemCache[i]
    if item and item.m_img_RedDot then
      local active = v:checkShowRed()
      item.m_img_RedDot.gameObject:SetActive(active)
    end
  end
end

function Form_ActivityMain:OnSelectIndex(index)
  if index == self.m_selectIndex then
    return
  end
  self.m_selectIndex = index
  local curActivity
  for i, v in ipairs(self.m_vActivityList) do
    local item = self.m_TabItemCache[i]
    local enable = index == i
    if enable then
      curActivity = v
    end
    item.m_tab_select:SetActive(enable)
    item.m_tab_unselect:SetActive(not enable)
  end
  if not curActivity then
    return
  end
  local activityId = curActivity:getID()
  local curSubPanelData = self.m_subPanelData[activityId]
  if not curSubPanelData then
    if not curActivity.getSubPanelName and not curActivity:getSubPanelName() then
      return
    end
    local panelName = curActivity:getSubPanelName()
    curSubPanelData = {IsActive = true}
    self.m_subPanelData[activityId] = curSubPanelData
    
    local function loadCallBack(subPanelLua)
      if subPanelLua then
        curSubPanelData.subPanelLua = subPanelLua
        subPanelLua:SetActive(curSubPanelData.IsActive)
      end
    end
    
    SubPanelManager:LoadSubPanel(panelName, self.m_root_activity, self, {
      cliveType = self.subPanelTabIndex
    }, {
      activity = curActivity,
      cliveType = self.subPanelTabIndex
    }, loadCallBack)
  end
  for k, v in pairs(self.m_subPanelData) do
    local isOpen = k == activityId
    if v.IsActive ~= isOpen then
      if v.subPanelLua and v.IsActive ~= isOpen then
        v.subPanelLua:SetActive(isOpen)
        if isOpen and self.subPanelTabIndex and v.subPanelLua.SetCurTabIdx then
          v.subPanelLua:SetCurTabIdx(self.subPanelTabIndex)
          self.subPanelTabIndex = nil
        end
      end
      v.IsActive = isOpen
      if v.subPanelLua and v.subPanelLua.killRemainTimer and not v.IsActive then
        v.subPanelLua:killRemainTimer()
      end
    end
    if v.IsActive and v.subPanelLua and v.subPanelLua.OnFreshData then
      if self.subPanelTabIndex and v.subPanelLua.SetCurTabIdx then
        v.subPanelLua:SetCurTabIdx(self.subPanelTabIndex)
        self.subPanelTabIndex = nil
      end
      v.subPanelLua:OnFreshData()
    end
  end
end

function Form_ActivityMain:RefreshActivityList()
  local activityList = ActivityManager:GetMainActivityList()
  self.m_vActivityList = {}
  for i, v in ipairs(activityList) do
    if v.SubPanelName and v.Activity:checkCondition(true) then
      table.insert(self.m_vActivityList, v.Activity)
    end
  end
  self:RefreshTableButtonList()
end

function Form_ActivityMain:OnInactive()
  self.super.OnInactive(self)
  if self.m_subPanelData then
    for i, info in pairs(self.m_subPanelData) do
      if info.subPanelLua and info.subPanelLua.killRemainTimer then
        info.subPanelLua:killRemainTimer()
      end
      if info.subPanelLua and info.subPanelLua.OnInactive then
        info.subPanelLua:OnInactive()
      end
    end
  end
  self:clearEventListener()
end

function Form_ActivityMain:OnDestroy()
  self.super.OnDestroy(self)
  self.m_TabItemCache = {}
  if self.m_subPanelData then
    for i, info in pairs(self.m_subPanelData) do
      if info.subPanelLua and info.subPanelLua.OnInactive then
        info.subPanelLua:OnInactive()
      end
      if info.subPanelLua and info.subPanelLua.dispose then
        info.subPanelLua:dispose()
        info.subPanelLua = nil
      end
    end
  end
  self:clearEventListener()
end

function Form_ActivityMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYMAIN)
end

function Form_ActivityMain:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

function Form_ActivityMain:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(ActivityManager.ActivitySubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  return vPackage, vResourceExtra
end

function Form_ActivityMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMain", Form_ActivityMain)
return Form_ActivityMain
