local Form_PersonalChange = class("Form_PersonalChange", require("UI/UIFrames/Form_PersonalChangeUI"))
local PlayerHeadIns = ConfigManager:GetConfigInsByName("PlayerHead")
local PlayerHeadFrameIns = ConfigManager:GetConfigInsByName("PlayerHeadFrame")
local RolePageType = {Head = 1, HeadFrame = 2}
local DefaultIndex = 1
local MaxPageToggleNum = 2
local MaxHeadToggleNum = 4
local MaxHeadFrameToggleNum = 4
local DeltaFrameNum = 30

function Form_PersonalChange:SetInitParam(param)
end

function Form_PersonalChange:Init(gameObject, csui)
  self:CreateTabClkBackFunctions()
  Form_PersonalChange.super.Init(self, gameObject, csui)
end

function Form_PersonalChange:AfterInit()
  self.super.AfterInit(self)
  self.m_leftHeadFrameTrans = self.m_icon_left_head_frame.transform
  self.m_img_headFrameTrans = self.m_img_headfarme.transform
  self.m_headToggleTab = {
    [1] = {
      nodeSelect = self.m_Head_Tab_Choose1,
      filterIndex = 0
    },
    [2] = {
      nodeSelect = self.m_Head_Tab_Choose2,
      filterIndex = 1
    },
    [3] = {
      nodeSelect = self.m_Head_Tab_Choose3,
      filterIndex = 2
    },
    [4] = {
      nodeSelect = self.m_Head_Tab_Choose4,
      filterIndex = 3
    }
  }
  self.m_headFrameToggleTab = {
    [1] = {
      nodeSelect = self.m_Frame_Tab_Choose1,
      filterIndex = 0
    },
    [2] = {
      nodeSelect = self.m_Frame_Tab_Choose2,
      filterIndex = 1
    },
    [3] = {
      nodeSelect = self.m_Frame_Tab_Choose3,
      filterIndex = 2
    },
    [4] = {
      nodeSelect = self.m_Frame_Tab_Choose4,
      filterIndex = 3
    }
  }
  self.PageToggleTab = {
    [RolePageType.Head] = {
      toggleIndex = nil,
      panelNode = self.m_pnl_exchangehead,
      nodeSelect = self.m_img_page1,
      contentNode = self.m_head_content,
      animStr = "PersonalChange_hero",
      freshFun = self.FreshHeadPanelShow,
      changeToggleFun = self.ChangeHeadToggleShow
    },
    [RolePageType.HeadFrame] = {
      toggleIndex = nil,
      panelNode = self.m_pnl_exchangeheadfarme,
      nodeSelect = self.m_img_page2,
      contentNode = self.m_head_frame_content,
      animStr = "PersonalChange_hero",
      freshFun = self.FreshHeadFramePanelShow,
      changeToggleFun = self.ChangeHeadFrameToggleShow
    }
  }
  self.m_paramChooseIndex = nil
  self.m_paramFilterIndex = nil
  self.m_paramChooseID = nil
  local initGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnRoleHeadItemClk(itemIndex)
    end
  }
  self.m_luaHeadInfinityGrid = self:CreateInfinityGrid(self.m_scroll_herohead_InfinityGrid, "PersonalRole/UIRoleHeadItem", initGridData)
  local initHeadFrameGridData = {
    itemClkBackFun = function(itemIndex)
      self:OnRoleHeadFrameItemClk(itemIndex)
    end
  }
  self.m_luaHeadFrameInfinityGrid = self:CreateInfinityGrid(self.m_scroll_headfarme_InfinityGrid, "PersonalRole/UIRoleHeadFrameItem", initHeadFrameGridData)
  self.m_curPageIndex = nil
  self.m_headDataList = nil
  self.m_showHeadDataList = nil
  self.m_headFrameDataList = nil
  self.m_showHeadFrameDataList = nil
  self.m_curUseHeadID = nil
  self.m_curHeadID = nil
  self.m_curUseHeadFrameID = nil
  self.m_curHeadFrameID = nil
  self.m_headFrameEndTime = nil
  self.m_isHaveHeadFrameUpdate = nil
  self.m_curFrameDeltaNum = 0
  self.m_leftHeadFrameEftNameStr = nil
  self.m_leftHeadFrameEftNodeObj = nil
  self.m_contentHeadFrameEftStr = nil
  self.m_contentHeadFrameEftObj = nil
end

function Form_PersonalChange:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
  self:RegisterRedDot()
end

function Form_PersonalChange:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:CheckRecycleHeadFrameNode()
  self:RemoveAllEventListeners()
end

function Form_PersonalChange:OnUpdate(dt)
  if self.m_isHaveHeadFrameUpdate then
    if self.m_curFrameDeltaNum < DeltaFrameNum then
      self.m_curFrameDeltaNum = self.m_curFrameDeltaNum + 1
    else
      self.m_curFrameDeltaNum = 0
      self:FreshHeadFrameLeftTimeStr()
    end
  end
end

function Form_PersonalChange:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleHeadFrameNode()
end

function Form_PersonalChange:FreshData()
  self.m_paramChooseIndex = nil
  self.m_paramFilterIndex = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_paramChooseIndex = tParam.chooseIndex
    self.m_paramFilterIndex = tParam.filterIndex
    self.m_paramChooseID = tParam.chooseID
    self.m_csui.m_param = nil
  end
  self.m_curHeadID = RoleManager:GetHeadID()
  self.m_curUseHeadID = RoleManager:GetHeadID()
  self.m_curHeadFrameID = RoleManager:GetHeadFrameID()
  self.m_curUseHeadFrameID = RoleManager:GetHeadFrameID()
  self:InitCreateListData()
  self.m_paramChooseID = nil
end

function Form_PersonalChange:InitCreateListData()
  local allHeadCfgDic = PlayerHeadIns:GetAll()
  local toChooseHeadID = self.m_curHeadID
  if self.m_paramChooseIndex == RolePageType.Head and self.m_paramChooseID ~= nil then
    toChooseHeadID = self.m_paramChooseID
  end
  self.m_headDataList = {}
  for _, v in pairs(allHeadCfgDic) do
    local isPlayerHeadHid = RoleManager:IsPlayerHeadHide(v)
    if isPlayerHeadHid ~= true then
      local tempHeadData = {
        cfg = v,
        isSelect = v.m_HeadID == toChooseHeadID,
        isHave = ItemManager:GetItemNum(v.m_HeadID) > 0
      }
      self.m_headDataList[#self.m_headDataList + 1] = tempHeadData
    end
  end
  table.sort(self.m_headDataList, function(a, b)
    local headIDA = a.cfg.m_HeadID
    local headIDB = b.cfg.m_HeadID
    local isUseA = headIDA == self.m_curUseHeadID
    local isUseB = headIDB == self.m_curUseHeadID
    if isUseA ~= isUseB then
      return isUseA
    end
    local isNewA = RoleManager:GetRoleHeadNewFlag(headIDA)
    local isNewB = RoleManager:GetRoleHeadNewFlag(headIDB)
    if isNewA ~= isNewB then
      return isNewA
    end
    if a.isHave ~= b.isHave then
      return a.isHave
    end
    return headIDA < headIDB
  end)
  local toChooseHeadFrameID = self.m_curHeadFrameID
  if self.m_paramChooseIndex == RolePageType.HeadFrame and self.m_paramChooseID ~= nil then
    toChooseHeadFrameID = self.m_paramChooseID
  end
  local allHeadFrameCfgDic = PlayerHeadFrameIns:GetAll()
  self.m_headFrameDataList = {}
  for _, v in pairs(allHeadFrameCfgDic) do
    local tempHideType = RoleManager:GetPlayerHeadFrameHideTypeValue(v.m_HeadFrameID, v.m_HideType) or 0
    local tempHideChannel = RoleManager:IsHeadFrameHideByChannel(v.m_HeadFrameID)
    if tempHideType ~= 1 and not tempHideChannel then
      local tempHeadFrameData = {
        cfg = v,
        isSelect = v.m_HeadFrameID == toChooseHeadFrameID,
        isHave = 0 < ItemManager:GetItemNum(v.m_HeadFrameID)
      }
      self.m_headFrameDataList[#self.m_headFrameDataList + 1] = tempHeadFrameData
    end
  end
  table.sort(self.m_headFrameDataList, function(a, b)
    local headIDA = a.cfg.m_HeadFrameID
    local headIDB = b.cfg.m_HeadFrameID
    local isUseA = headIDA == self.m_curUseHeadFrameID
    local isUseB = headIDB == self.m_curUseHeadFrameID
    if isUseA ~= isUseB then
      return isUseA
    end
    local isNewA = RoleManager:GetRoleHeadFrameNewFlag(headIDA)
    local isNewB = RoleManager:GetRoleHeadFrameNewFlag(headIDB)
    if isNewA ~= isNewB then
      return isNewA
    end
    if a.isHave ~= b.isHave then
      return a.isHave
    end
    return headIDA < headIDB
  end)
end

function Form_PersonalChange:FreshHeadDataList()
  self.m_showHeadDataList = {}
  local pageToggleData = self.PageToggleTab[self.m_curPageIndex]
  if not pageToggleData then
    return
  end
  local pageToggleIndex = pageToggleData.toggleIndex or DefaultIndex
  local headToggleData = self.m_headToggleTab[pageToggleIndex]
  local filterIndex = headToggleData.filterIndex
  if filterIndex == 0 then
    self.m_showHeadDataList = self.m_headDataList
  else
    for _, v in ipairs(self.m_headDataList) do
      if v.cfg.m_Tag == filterIndex then
        self.m_showHeadDataList[#self.m_showHeadDataList + 1] = v
      end
    end
  end
end

function Form_PersonalChange:FreshHeadFrameDataList()
  self.m_showHeadFrameDataList = {}
  local pageToggleData = self.PageToggleTab[self.m_curPageIndex]
  if not pageToggleData then
    return
  end
  local pageToggleIndex = pageToggleData.toggleIndex or DefaultIndex
  local headToggleData = self.m_headFrameToggleTab[pageToggleIndex]
  local filterIndex = headToggleData.filterIndex
  if filterIndex == 0 then
    self.m_showHeadFrameDataList = self.m_headFrameDataList
  else
    for _, v in ipairs(self.m_headFrameDataList) do
      if v.cfg.m_Tag == filterIndex then
        self.m_showHeadFrameDataList[#self.m_showHeadFrameDataList + 1] = v
      end
    end
  end
end

function Form_PersonalChange:GetHeadIndexByID(headID)
  if not headID then
    return
  end
  if not self.m_headDataList then
    return
  end
  for i, v in ipairs(self.m_headDataList) do
    if v.cfg.m_HeadID == headID then
      return i
    end
  end
end

function Form_PersonalChange:GetShowHeadIndexByID(headID)
  if not headID then
    return
  end
  if not self.m_showHeadDataList then
    return
  end
  for i, v in ipairs(self.m_showHeadDataList) do
    if v.cfg.m_HeadID == headID then
      return i
    end
  end
end

function Form_PersonalChange:GetHeadFrameIndexByID(headFrameID)
  if not headFrameID then
    return
  end
  if not self.m_headFrameDataList then
    return
  end
  for i, v in ipairs(self.m_headFrameDataList) do
    if v.cfg.m_HeadFrameID == headFrameID then
      return i
    end
  end
end

function Form_PersonalChange:GetShowHeadFrameIndexByID(headFrameID)
  if not headFrameID then
    return
  end
  if not self.m_showHeadFrameDataList then
    return
  end
  for i, v in ipairs(self.m_showHeadFrameDataList) do
    if v.cfg.m_HeadFrameID == headFrameID then
      return i
    end
  end
end

function Form_PersonalChange:ClearCacheData()
end

function Form_PersonalChange:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_head_tab_red_dot, RedDotDefine.ModuleType.PersonalCardHeadTab)
  self:RegisterOrUpdateRedDotItem(self.m_head_frame_tab_red_dot, RedDotDefine.ModuleType.PersonalCardHeadFrameTab)
end

function Form_PersonalChange:AddEventListeners()
  self:addEventListener("eGameEvent_RoleSetCard", handler(self, self.OnRoleSetCard))
end

function Form_PersonalChange:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalChange:OnRoleSetCard(paramTab)
  if not paramTab then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 51001)
  self:CloseForm()
end

function Form_PersonalChange:CreateTabClkBackFunctions()
  for i = 1, MaxPageToggleNum do
    local funStr = string.format("OnBtnpage%dClicked", i)
    self[funStr] = function()
      self:OnPageClk(i)
    end
  end
  for i = 1, MaxHeadToggleNum do
    local funStr = string.format("OnBtnHeadTab%dClicked", i)
    self[funStr] = function()
      self:OnHeadTabClk(i)
    end
  end
  for i = 1, MaxHeadFrameToggleNum do
    local funStr = string.format("OnBtnFrameTab%dClicked", i)
    self[funStr] = function()
      self:OnHeadFrameTabClk(i)
    end
  end
end

function Form_PersonalChange:FreshUI()
  self:FreshRoleBaseInfo()
  self:ClearToggleChooseStatus()
  local showPageIndex = self.m_paramChooseIndex or DefaultIndex
  self:ChangePageShow(showPageIndex)
  local pageToggleData = self.PageToggleTab[self.m_curPageIndex]
  if pageToggleData then
    if pageToggleData.changeToggleFun then
      pageToggleData.changeToggleFun(self, self.m_paramFilterIndex or DefaultIndex)
    end
    if pageToggleData.freshFun then
      pageToggleData.freshFun(self)
    end
  end
  self.m_paramFilterIndex = nil
  self.m_paramChooseIndex = nil
end

function Form_PersonalChange:ClearToggleChooseStatus()
  for i, v in ipairs(self.PageToggleTab) do
    if v.changeToggleFun then
      v.changeToggleFun(self, DefaultIndex)
    end
  end
end

function Form_PersonalChange:FreshRoleBaseInfo()
  self:FreshLeftHeadShow()
  self:FreshLeftHeadFrameShow()
  self.m_txt_name_Text.text = tostring(RoleManager:GetName())
  self.m_txt_level_Text.text = tostring(RoleManager:GetLevel())
  local roleExp = RoleManager:GetRoleExp() or 0
  local maxExp = RoleManager:GetRoleMaxExpNum(RoleManager:GetLevel())
  if maxExp then
    self.m_num_empirical_Text.text = roleExp .. "/" .. maxExp
    self.m_line_progress_Image.fillAmount = math.min(roleExp / maxExp, 1)
  else
    self.m_num_empirical_Text.text = "-/-"
    self.m_line_progress_Image.fillAmount = 1
  end
  self.m_txt_guild_tips_Text.text = RoleManager:GetAllianceName() or ""
  self.m_servenum_Text.text = UserDataManager:GetZoneID() or ""
  self.m_num_Text.text = UserDataManager:GetAccountID() or ""
end

function Form_PersonalChange:FreshLeftHeadShow()
  if not self.m_curHeadID then
    return
  end
  local roleHeadCfg = RoleManager:GetPlayerHeadCfg(self.m_curHeadID)
  if not roleHeadCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_head_Image, roleHeadCfg.m_HeadPic)
end

function Form_PersonalChange:CheckRecycleHeadFrameNode()
  if self.m_leftHeadFrameEftNameStr and self.m_leftHeadFrameEftNodeObj then
    utils.RecycleInParentUIPrefab(self.m_leftHeadFrameEftNameStr, self.m_leftHeadFrameEftNodeObj)
  end
  self.m_leftHeadFrameEftNameStr = nil
  self.m_leftHeadFrameEftNodeObj = nil
  if self.m_contentHeadFrameEftStr and self.m_contentHeadFrameEftObj then
    utils.RecycleInParentUIPrefab(self.m_contentHeadFrameEftStr, self.m_contentHeadFrameEftObj)
  end
  self.m_contentHeadFrameEftStr = nil
  self.m_contentHeadFrameEftObj = nil
end

function Form_PersonalChange:FreshLeftHeadFrameShow()
  if not self.m_curHeadFrameID then
    return
  end
  local roleHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(self.m_curHeadFrameID)
  if not roleHeadFrameCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_left_head_frame_Image, roleHeadFrameCfg.m_HeadFramePic, function()
    if not UILuaHelper.IsNull(self.m_icon_left_head_frame_Image) then
      UILuaHelper.SetNativeSize(self.m_icon_left_head_frame_Image)
    end
  end)
  if roleHeadFrameCfg.m_HeadFrameEft and roleHeadFrameCfg.m_HeadFrameEft ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_leftHeadFrameTrans, roleHeadFrameCfg.m_HeadFrameEft, function(nameStr, gameObject)
      self.m_leftHeadFrameEftNameStr = nameStr
      self.m_leftHeadFrameEftNodeObj = gameObject
      self:FreshShowLeftHeadFrameChild()
    end)
  else
    UILuaHelper.SetActiveChildren(self.m_leftHeadFrameTrans, false)
  end
end

function Form_PersonalChange:FreshShowLeftHeadFrameChild()
  if not self.m_curHeadFrameID then
    return
  end
  local playerHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(self.m_curHeadFrameID)
  if not playerHeadFrameCfg then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_leftHeadFrameTrans, false)
  if playerHeadFrameCfg.m_HeadFrameEft then
    local subNode = self.m_leftHeadFrameTrans:Find(playerHeadFrameCfg.m_HeadFrameEft)
    if subNode then
      UILuaHelper.SetActive(subNode, true)
    end
  end
end

function Form_PersonalChange:ChangePageShow(index)
  if self.m_curPageIndex then
    local pageToggleData = self.PageToggleTab[self.m_curPageIndex]
    if pageToggleData then
      UILuaHelper.SetActive(pageToggleData.panelNode, false)
      UILuaHelper.SetActive(pageToggleData.nodeSelect, false)
    end
  end
  self.m_curPageIndex = index
  if index then
    local toShowPageToggleData = self.PageToggleTab[index]
    if toShowPageToggleData then
      UILuaHelper.SetActive(toShowPageToggleData.panelNode, true)
      UILuaHelper.SetActive(toShowPageToggleData.nodeSelect, true)
    end
  end
end

function Form_PersonalChange:FreshButtonsShow()
  local headFrameID = RoleManager:GetHeadFrameID()
  local headID = RoleManager:GetHeadID()
  local isHaveChange = headFrameID ~= self.m_curHeadFrameID or headID ~= self.m_curHeadID
  UILuaHelper.SetActive(self.m_btn_reset, isHaveChange)
  UILuaHelper.SetActive(self.m_btn_reset_gray, not isHaveChange)
end

function Form_PersonalChange:CheckStartHeadFrameLeftTime()
  if not self.m_curHeadFrameID then
    return
  end
  local expireTime = ItemManager:GetItemExpireTime(self.m_curHeadFrameID)
  local serverTime = TimeUtil:GetServerTimeS()
  if expireTime and expireTime > serverTime then
    local leftSec = expireTime - serverTime
    self.m_txt_lefttimeheadfarme_Text.text = TimeUtil:SecondToTimeText(leftSec)
    self.m_curFrameDeltaNum = 0
    self.m_headFrameEndTime = expireTime
    self.m_isHaveHeadFrameUpdate = true
    self:FreshHeadFrameLeftTimeStr()
  else
    self.m_isHaveHeadFrameUpdate = false
    self.m_curFrameDeltaNum = 0
    self.m_headFrameEndTime = nil
    UILuaHelper.SetActive(self.m_pnl_left_time, false)
  end
end

function Form_PersonalChange:FreshHeadFrameLeftTimeStr()
  if not self.m_headFrameEndTime then
    return
  end
  local serverTime = TimeUtil:GetServerTimeS()
  local leftSec = self.m_headFrameEndTime - serverTime
  if leftSec <= 0 then
    UILuaHelper.SetActive(self.m_pnl_left_time, false)
    self.m_isHaveHeadFrameUpdate = false
    self.m_curFrameDeltaNum = 0
    self.m_headFrameEndTime = nil
    self.m_curUseHeadFrameID = RoleManager:GetHeadFrameID()
    self:InitCreateListData()
    self:FreshFilterHeadFrameList()
    self:FreshLeftHeadFrameShow()
    self:FreshHeadFrameContentShow()
    self:FreshButtonsShow()
  else
    UILuaHelper.SetActive(self.m_pnl_left_time, true)
    self.m_txt_lefttimeheadfarme_Text.text = TimeUtil:SecondToTimeText(leftSec)
  end
end

function Form_PersonalChange:FreshHeadPanelShow()
  if not self.m_curPageIndex then
    return
  end
  local pageToggleData = self.PageToggleTab[self.m_curPageIndex]
  if not pageToggleData then
    return
  end
  self:FreshFilterHeadList(true)
  self:FreshHeadContentShow()
  self:FreshLeftHeadShow()
  self:FreshButtonsShow()
end

function Form_PersonalChange:ChangeHeadToggleShow(pageIndex)
  local headToggleData = self.PageToggleTab[RolePageType.Head]
  if not headToggleData then
    return
  end
  local lastToggleIndex = headToggleData.toggleIndex
  if lastToggleIndex then
    local lastHeadToggleData = self.m_headToggleTab[lastToggleIndex]
    if lastHeadToggleData then
      UILuaHelper.SetActive(lastHeadToggleData.nodeSelect, false)
    end
  end
  headToggleData.toggleIndex = pageIndex
  local curHeadToggleData = self.m_headToggleTab[pageIndex]
  if curHeadToggleData then
    UILuaHelper.SetActive(curHeadToggleData.nodeSelect, true)
  end
end

function Form_PersonalChange:FreshFilterHeadList(isResetPos)
  self:FreshHeadDataList()
  self:FreshHeadListShow(isResetPos)
end

function Form_PersonalChange:FreshHeadListShow(isResetPos)
  if not self.m_showHeadDataList then
    return
  end
  self.m_luaHeadInfinityGrid:ShowItemList(self.m_showHeadDataList)
  if isResetPos then
    self.m_luaHeadInfinityGrid:LocateTo()
  end
  local headToggleData = self.PageToggleTab[RolePageType.Head]
  if headToggleData then
    UILuaHelper.PlayAnimationByName(headToggleData.contentNode, headToggleData.animStr)
  end
end

function Form_PersonalChange:FreshHeadContentShow()
  if not self.m_curHeadID then
    return
  end
  local playerHeadCfg = RoleManager:GetPlayerHeadCfg(self.m_curHeadID)
  if not playerHeadCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_playerhead_Image, playerHeadCfg.m_HeadPic)
  self.m_txt_playerinfor1_Text.text = playerHeadCfg.m_mGetwayDes
  self.m_txt_head_name_Text.text = playerHeadCfg.m_mHeadName
end

function Form_PersonalChange:FreshHeadFramePanelShow()
  if not self.m_curPageIndex then
    return
  end
  local pageToggleData = self.PageToggleTab[self.m_curPageIndex]
  if not pageToggleData then
    return
  end
  self:FreshFilterHeadFrameList(true)
  self:FreshHeadFrameContentShow()
  self:FreshLeftHeadFrameShow()
  self:FreshButtonsShow()
end

function Form_PersonalChange:ChangeHeadFrameToggleShow(pageIndex)
  local headFrameToggleData = self.PageToggleTab[RolePageType.HeadFrame]
  if not headFrameToggleData then
    return
  end
  local lastToggleIndex = headFrameToggleData.toggleIndex
  if lastToggleIndex then
    local lastHeadFrameToggleData = self.m_headFrameToggleTab[lastToggleIndex]
    if lastHeadFrameToggleData then
      UILuaHelper.SetActive(lastHeadFrameToggleData.nodeSelect, false)
    end
  end
  headFrameToggleData.toggleIndex = pageIndex
  local curHeadFrameToggleData = self.m_headFrameToggleTab[pageIndex]
  if curHeadFrameToggleData then
    UILuaHelper.SetActive(curHeadFrameToggleData.nodeSelect, true)
  end
end

function Form_PersonalChange:FreshFilterHeadFrameList(isResetPos)
  self:FreshHeadFrameDataList()
  self:FreshHeadFrameListShow(isResetPos)
end

function Form_PersonalChange:FreshHeadFrameListShow(isResetPos)
  if not self.m_showHeadFrameDataList then
    return
  end
  self.m_luaHeadFrameInfinityGrid:ShowItemList(self.m_showHeadFrameDataList)
  if isResetPos then
    self.m_luaHeadFrameInfinityGrid:LocateTo()
  end
  local headFrameToggleData = self.PageToggleTab[RolePageType.HeadFrame]
  if headFrameToggleData then
    UILuaHelper.PlayAnimationByName(headFrameToggleData.contentNode, headFrameToggleData.animStr)
  end
end

function Form_PersonalChange:FreshHeadFrameContentShow()
  if not self.m_curHeadFrameID then
    return
  end
  local playerHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(self.m_curHeadFrameID)
  if not playerHeadFrameCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_headfarme_Image, playerHeadFrameCfg.m_HeadFramePic, function()
    if not UILuaHelper.IsNull(self.m_img_headfarme_Image) then
      UILuaHelper.SetNativeSize(self.m_img_headfarme_Image)
    end
  end)
  if playerHeadFrameCfg.m_HeadFrameEft and playerHeadFrameCfg.m_HeadFrameEft ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_img_headFrameTrans, playerHeadFrameCfg.m_HeadFrameEft, function(nameStr, gameObject)
      self.m_contentHeadFrameEftStr = nameStr
      self.m_contentHeadFrameEftObj = gameObject
      self:FreshShowHeadFrameChild()
    end)
  else
    UILuaHelper.SetActiveChildren(self.m_img_headFrameTrans, false)
  end
  self.m_txt_head_frame_name_Text.text = playerHeadFrameCfg.m_mHeadName
  self.m_txt_playerinforheadfarme_Text.text = playerHeadFrameCfg.m_mGetwayDes
  self:CheckStartHeadFrameLeftTime()
end

function Form_PersonalChange:FreshShowHeadFrameChild()
  if not self.m_curHeadFrameID then
    return
  end
  local playerHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(self.m_curHeadFrameID)
  if not playerHeadFrameCfg then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_img_headfarme, false)
  if playerHeadFrameCfg.m_HeadFrameEft then
    local subNode = self.m_img_headFrameTrans:Find(playerHeadFrameCfg.m_HeadFrameEft)
    if subNode then
      UILuaHelper.SetActive(subNode, true)
    end
  end
end

function Form_PersonalChange:OnRoleHeadItemClk(headIndex)
  if not headIndex then
    return
  end
  local toChooseHeadItemData = self.m_showHeadDataList[headIndex]
  if not toChooseHeadItemData then
    return
  end
  local toChooseHeadID = toChooseHeadItemData.cfg.m_HeadID
  if toChooseHeadID == self.m_curHeadID then
    return
  end
  local curChooseIndex = self:GetShowHeadIndexByID(self.m_curHeadID)
  if curChooseIndex then
    local showItem = self.m_luaHeadInfinityGrid:GetShowItemByIndex(curChooseIndex)
    if showItem then
      showItem:ChangeItemChooseStatus(false)
    else
      local showItemData = self.m_showHeadDataList[curChooseIndex]
      showItemData.isSelect = false
    end
  else
    local allHeadIndex = self:GetHeadIndexByID(self.m_curHeadID)
    if allHeadIndex then
      local headItemData = self.m_headDataList[allHeadIndex]
      headItemData.isSelect = false
    end
  end
  local toShowItem = self.m_luaHeadInfinityGrid:GetShowItemByIndex(headIndex)
  if toShowItem then
    toShowItem:ChangeItemChooseStatus(true)
    toShowItem:ShowChooseStatusAnim()
  end
  self.m_curHeadID = toChooseHeadID
  self:FreshLeftHeadShow()
  self:FreshHeadContentShow()
  self:FreshButtonsShow()
end

function Form_PersonalChange:OnRoleHeadFrameItemClk(headFrameIndex)
  if not headFrameIndex then
    return
  end
  local toChooseHeadFrameItemData = self.m_showHeadFrameDataList[headFrameIndex]
  if not toChooseHeadFrameItemData then
    return
  end
  local toChooseHeadFrameID = toChooseHeadFrameItemData.cfg.m_HeadFrameID
  if toChooseHeadFrameID == self.m_curHeadFrameID then
    return
  end
  local curChooseIndex = self:GetShowHeadFrameIndexByID(self.m_curHeadFrameID)
  if curChooseIndex then
    local showItem = self.m_luaHeadFrameInfinityGrid:GetShowItemByIndex(curChooseIndex)
    if showItem then
      showItem:ChangeItemChooseStatus(false)
    else
      local showItemData = self.m_showHeadFrameDataList[curChooseIndex]
      showItemData.isSelect = false
    end
  else
    local allHeadIndex = self:GetHeadFrameIndexByID(self.m_curHeadFrameID)
    if allHeadIndex then
      local headFrameItemData = self.m_headFrameDataList[allHeadIndex]
      headFrameItemData.isSelect = false
    end
  end
  local toShowItem = self.m_luaHeadFrameInfinityGrid:GetShowItemByIndex(headFrameIndex)
  if toShowItem then
    toShowItem:ChangeItemChooseStatus(true)
    toShowItem:ShowChooseStatusAnim()
  end
  self.m_curHeadFrameID = toChooseHeadFrameID
  self:FreshLeftHeadFrameShow()
  self:FreshHeadFrameContentShow()
  self:FreshButtonsShow()
end

function Form_PersonalChange:OnPageClk(index)
  if index == self.m_curPageIndex then
    return
  end
  self:ChangePageShow(index)
  local toggleTab = self.PageToggleTab[self.m_curPageIndex]
  if not toggleTab then
    return
  end
  if toggleTab.changeToggleFun then
    toggleTab.changeToggleFun(self, toggleTab.toggleIndex or DefaultIndex)
  end
  if toggleTab.freshFun then
    toggleTab.freshFun(self)
  end
end

function Form_PersonalChange:OnHeadTabClk(index)
  if self.m_curPageIndex ~= RolePageType.Head then
    return
  end
  local togglePageData = self.PageToggleTab[RolePageType.Head]
  if not togglePageData then
    return
  end
  local curHeadToggleIndex = togglePageData.toggleIndex
  if curHeadToggleIndex == index then
    return
  end
  self:ChangeHeadToggleShow(index)
  if togglePageData.freshFun then
    togglePageData.freshFun(self)
  end
end

function Form_PersonalChange:OnHeadFrameTabClk(index)
  if self.m_curPageIndex ~= RolePageType.HeadFrame then
    return
  end
  local togglePageData = self.PageToggleTab[RolePageType.HeadFrame]
  if not togglePageData then
    return
  end
  local curHeadToggleIndex = togglePageData.toggleIndex
  if curHeadToggleIndex == index then
    return
  end
  self:ChangeHeadFrameToggleShow(index)
  if togglePageData.freshFun then
    togglePageData.freshFun(self)
  end
end

function Form_PersonalChange:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PersonalChange:OnBtnresetClicked()
  self.m_curHeadID = RoleManager:GetHeadID()
  self.m_curUseHeadID = self.m_curHeadID
  self.m_curHeadFrameID = RoleManager:GetHeadFrameID()
  self.m_curUseHeadFrameID = self.m_curHeadFrameID
  self:InitCreateListData()
  self:FreshFilterHeadList()
  self:FreshFilterHeadFrameList()
  self:FreshLeftHeadShow()
  self:FreshLeftHeadFrameShow()
  self:FreshHeadContentShow()
  self:FreshHeadFrameContentShow()
  self:FreshButtonsShow()
end

function Form_PersonalChange:OnBtnresetgrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 51004)
end

function Form_PersonalChange:OnBtnCancelClicked()
  self:CloseForm()
end

function Form_PersonalChange:OnBtnConfirmClicked()
  if self.m_curHeadID == self.m_curUseHeadID and self.m_curHeadFrameID == self.m_curUseHeadFrameID then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 51003)
    self:CloseForm()
    return
  end
  local isHaveHead = ItemManager:GetItemNum(self.m_curHeadID) > 0
  local isHaveHeadFrame = ItemManager:GetItemNum(self.m_curHeadFrameID) > 0
  if not isHaveHead or not isHaveHeadFrame then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 51002)
    return
  end
  RoleManager:ReqRoleSetCard(self.m_curHeadID, self.m_curHeadFrameID)
end

function Form_PersonalChange:OnBtniconcopybgClicked()
  UILuaHelper.CopyTextToClipboard(tostring(RoleManager:GetUID()))
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20025)
end

local f
ullscreen = true
ActiveLuaUI("Form_PersonalChange", Form_PersonalChange)
return Form_PersonalChange
