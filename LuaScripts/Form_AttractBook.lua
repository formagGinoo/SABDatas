local Form_AttractBook = class("Form_AttractBook", require("UI/UIFrames/Form_AttractBookUI"))
local SELECT_COLOR = CS.UnityEngine.Color(0.9137254901960784, 0.8470588235294118, 0.7490196078431373, 1)
local NORMAL_COLOR = CS.UnityEngine.Color(0.7098039215686275, 0.6980392156862745, 0.6705882352941176, 1)
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")

function Form_AttractBook:SetInitParam(param)
end

function Form_AttractBook:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node2/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1101)
  self.m_subPanelData = {
    [AttractManager.BookType.Prologue] = {
      panelRoot = self.m_panel_prologue_root,
      subPanelName = "AttractPrologueSubPanel",
      subPanelLua = nil
    },
    [AttractManager.BookType.Dialogue] = {
      panelRoot = self.m_panel_dialogue_root,
      subPanelName = "AttractDialogueSubPanel",
      subPanelLua = nil
    },
    [AttractManager.BookType.Timeline] = {
      panelRoot = self.m_panel_timeline_root,
      subPanelName = "AttractTimelineSubPanel",
      subPanelLua = nil
    },
    [AttractManager.BookType.Biography] = {
      panelRoot = self.m_panel_biography_root,
      subPanelName = "AttractBiographySubPanel",
      subPanelLua = nil
    },
    [AttractManager.BookType.Faction] = {
      panelRoot = self.m_panel_faction_root,
      subPanelName = "AttractFactionSubPanel",
      subPanelLua = nil
    }
  }
  for k, v in ipairs(self.m_subPanelData) do
    v.panelRoot:SetActive(false)
  end
end

function Form_AttractBook:OnActive()
  self.super.OnActive(self)
  self:addEventListener("eGameEvent_AttractBook_Change_Tab", handler(self, self.OnChangeTab))
  self:addEventListener("eGameEvent_Hero_AttractRedCheck", handler(self, self.OnAttractRedCheck))
  self:addEventListener("eGameEvent_AttractBook_Show_Timeline", handler(self, self.OnAttractShowTimeline))
  self:InitView()
  GlobalManagerIns:TriggerWwiseBGMState(64)
end

function Form_AttractBook:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_AttractBook:GetDownloadResourceExtra(tParam)
  local vSubPanelName = {
    "AttractDialogueSubPanel",
    "AttractPrologueSubPanel",
    "AttractTimelineSubPanel",
    "AttractBiographySubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
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

function Form_AttractBook:OnDestroy()
  self.super.OnDestroy(self)
  for i, panelData in pairs(self.m_subPanelData) do
    if panelData.subPanelLua ~= nil then
      panelData.subPanelLua:dispose()
      panelData.subPanelLua = nil
    end
  end
end

function Form_AttractBook:OnAttractRedCheck()
  if self.m_loop_scroll_view then
    self.m_loop_scroll_view:updateCellIndex(0)
  end
end

function Form_AttractBook:InitView()
  self:InitTab()
end

function Form_AttractBook:RefreshTabLoopScroll()
  local data = self.m_tabData
  if self.m_savedSelectedIndex then
    self.m_selectedIndex = self.m_savedSelectedIndex or 1
    self.m_savedSelectedIndex = nil
  else
    self.m_selectedIndex = 1
  end
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_scrollview_tab
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if self.m_loop_scroll_view:getDragFlag() or index == self.m_selectedIndex then
          return
        end
        GlobalManagerIns:TriggerWwiseBGMState(65)
        local lastSelectedIndex = self.m_selectedIndex
        if click_name == "c_btn_click1" or click_name == "c_btn_click2" then
          LuaBehaviourUtil.setObjectVisible(UIUtil.findLuaBehaviour(cell_object.transform), "c_bg_select", true)
          self.m_selectedIndex = index
          self:CheckTabRedDot(index, cell_object, cell_data)
          self.m_loop_scroll_view:updateCellIndex(lastSelectedIndex - 1)
        end
        self:SelectTab(self.m_selectedIndex)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_AttractBook:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local c_item_root = luaBehaviour:FindGameObject("c_item_root")
  local txtName
  if cell_data.isSub then
    txtName = "c_txt_tab2_name"
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_tab1", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_tab2", true)
  else
    txtName = "c_txt_tab1_name"
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_tab1", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_tab2", false)
  end
  if self.m_selectedIndex == index then
    LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, txtName, SELECT_COLOR)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_select", true)
  else
    LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, txtName, NORMAL_COLOR)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_select", false)
  end
  local iType = cell_data.iType
  if iType == AttractManager.BookType.Prologue then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, txtName, CommonTextIns:GetValue_ById(100054).m_mMessage)
  elseif iType == AttractManager.BookType.Biography then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, txtName, CommonTextIns:GetValue_ById(100055).m_mMessage)
  elseif iType == AttractManager.BookType.Faction then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, txtName, CommonTextIns:GetValue_ById(100056).m_mMessage)
  elseif iType == AttractManager.BookType.Dialogue then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, txtName, CommonTextIns:GetValue_ById(100057).m_mMessage)
  elseif iType == AttractManager.BookType.Timeline then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, txtName, cell_data.stTimeline.m_mHeadline)
  end
  self:CheckTabRedDot(index, cell_object, cell_data)
end

function Form_AttractBook:CheckTabRedDot(index, cell_object, cell_data)
  local iType = cell_data.iType
  local redDot = false
  if self.m_selectedIndex ~= index then
    local heroID = cell_data.iHeroId
    if iType == AttractManager.BookType.Prologue then
      local vStoryIds = {}
      for k, v in ipairs(cell_data.vBiography) do
        vStoryIds[#vStoryIds + 1] = v.m_StoryId
      end
      for k, v in ipairs(cell_data.vFaction) do
        vStoryIds[#vStoryIds + 1] = v.m_StoryId
      end
      for k, v in ipairs(vStoryIds) do
        if AttractManager:CheckStoryNew(heroID, v) or AttractManager:CanReceiveGift(heroID, v) then
          redDot = true
          break
        end
      end
    elseif iType == AttractManager.BookType.Biography then
      local vStoryIds = {}
      for k, v in ipairs(cell_data.vBiography) do
        vStoryIds[#vStoryIds + 1] = v.m_StoryId
      end
      for k, v in ipairs(vStoryIds) do
        if AttractManager:CheckStoryNew(heroID, v) or AttractManager:CanReceiveGift(heroID, v) then
          redDot = true
          break
        end
      end
    elseif iType == AttractManager.BookType.Faction then
      local vStoryIds = {}
      for k, v in ipairs(cell_data.vFaction) do
        vStoryIds[#vStoryIds + 1] = v.m_StoryId
      end
      for k, v in ipairs(vStoryIds) do
        if AttractManager:CheckStoryNew(heroID, v) or AttractManager:CanReceiveGift(heroID, v) then
          redDot = true
          break
        end
      end
    elseif iType == AttractManager.BookType.Dialogue then
    elseif iType == AttractManager.BookType.Timeline then
      local iStoryId = cell_data.stTimeline.m_StoryId
      local stPreTimeline = cell_data.stPreTimeline
      if AttractManager:CheckStoryNew(heroID, iStoryId) or AttractManager:CanReceiveGift(heroID, iStoryId, false) then
        redDot = true
      end
    end
  end
  LuaBehaviourUtil.setObjectVisible(UIUtil.findLuaBehaviour(cell_object.transform), "c_img_red", redDot)
end

function Form_AttractBook:InitTab()
  local tParam = self.m_csui.m_param
  self.m_curShowHeroData = tParam.curShowHeroData
  local iHeroId = self.m_curShowHeroData.characterCfg.m_HeroID
  local stAttractStory = ConfigManager:GetConfigInsByName("AttractStory")
  local vStory = stAttractStory:GetValue_ByHeroID(iHeroId)
  local vBiography = {}
  local vFaction = {}
  local vTimeline = {}
  for k, v in pairs(vStory) do
    if v.m_Type == 1 then
      vBiography[#vBiography + 1] = v
    elseif v.m_Type == 2 then
      vFaction[#vFaction + 1] = v
    elseif v.m_Type == 3 then
      vTimeline[#vTimeline + 1] = v
    end
  end
  
  local function sortFunc(a, b)
    return a.m_StoryId < b.m_StoryId
  end
  
  if 1 < #vBiography then
    table.sort(vBiography, sortFunc)
  end
  if 1 < #vFaction then
    table.sort(vFaction, sortFunc)
  end
  if 1 < #vTimeline then
    table.sort(vTimeline, sortFunc)
  end
  local stAttractVoiceInfo = ConfigManager:GetConfigInsByName("AttractVoiceInfo")
  local vVoiceInfo = {}
  local stVoiceInfo = stAttractVoiceInfo:GetValue_ByHeroID(iHeroId)
  for k, v in pairs(stVoiceInfo) do
    vVoiceInfo[#vVoiceInfo + 1] = v
  end
  if 1 < #vVoiceInfo then
    table.sort(vVoiceInfo, function(a, b)
      if a.m_Sort == b.m_Sort then
        return a.m_VoiceId < b.m_VoiceId
      end
      return a.m_Sort < b.m_Sort
    end)
  end
  self.m_tabData = {}
  self.m_tabData[#self.m_tabData + 1] = {
    iType = AttractManager.BookType.Prologue,
    iHeroId = iHeroId,
    vBiography = vBiography,
    vFaction = vFaction,
    vTimeline = vTimeline
  }
  if 0 < #vBiography then
    self.m_tabData[#self.m_tabData + 1] = {
      iType = AttractManager.BookType.Biography,
      iHeroId = iHeroId,
      vBiography = vBiography,
      isSub = true
    }
  end
  if 0 < #vVoiceInfo then
    self.m_tabData[#self.m_tabData + 1] = {
      iType = AttractManager.BookType.Dialogue,
      iHeroId = iHeroId,
      vVoiceInfo = vVoiceInfo,
      isSub = true
    }
  end
  for k, v in ipairs(vTimeline) do
    self.m_tabData[#self.m_tabData + 1] = {
      iType = AttractManager.BookType.Timeline,
      iHeroId = iHeroId,
      stTimeline = v
    }
  end
  self:RefreshTabLoopScroll()
  self:SelectTab(self.m_selectedIndex)
end

function Form_AttractBook:SelectTab(iTab)
  self:FreshContent(self.m_tabData[iTab].iType, self.m_tabData[iTab])
end

function Form_AttractBook:FreshContent(iType, stContentData)
  local curSubPanelData = self.m_subPanelData[iType]
  if self.m_lastContentType ~= nil and self.m_lastContentType ~= iType then
    local lastSubPanelData = self.m_subPanelData[self.m_lastContentType]
    lastSubPanelData.panelRoot:SetActive(false)
    if lastSubPanelData.subPanelLua and lastSubPanelData.subPanelLua.OnInactivePanel then
      lastSubPanelData.subPanelLua:OnInactivePanel()
    end
  end
  self.m_lastContentType = iType
  curSubPanelData.panelRoot:SetActive(true)
  if curSubPanelData.subPanelLua == nil then
    SubPanelManager:LoadSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, nil, {
      curShowHeroData = self.m_curShowHeroData,
      stContentData = stContentData
    }, function(subPanelLua)
      if subPanelLua then
        curSubPanelData.subPanelLua = subPanelLua
        if subPanelLua.OnActivePanel then
          subPanelLua:OnActivePanel()
        end
      end
    end)
  else
    curSubPanelData.subPanelLua:FreshData({
      curShowHeroData = self.m_curShowHeroData,
      stContentData = stContentData
    })
    if curSubPanelData.subPanelLua.OnActivePanel then
      curSubPanelData.subPanelLua:OnActivePanel()
    end
  end
end

function Form_AttractBook:OnBackClk()
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_ATTRACTBOOK)
end

function Form_AttractBook:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_AttractBook:OnChangeTab(iType)
  local iTab = -1
  for k, v in ipairs(self.m_tabData) do
    if v.iType == iType then
      iTab = k
      break
    end
  end
  if iTab == -1 then
    return
  end
  local lastSelectedIndex = self.m_selectedIndex
  self.m_selectedIndex = iTab
  self.m_loop_scroll_view:updateCellIndex(iTab - 1)
  self.m_loop_scroll_view:updateCellIndex(lastSelectedIndex - 1)
  self:SelectTab(self.m_selectedIndex)
end

function Form_AttractBook:OnAttractShowTimeline()
  self.m_savedSelectedIndex = self.m_selectedIndex
end

function Form_AttractBook:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_AttractBook", Form_AttractBook)
return Form_AttractBook
