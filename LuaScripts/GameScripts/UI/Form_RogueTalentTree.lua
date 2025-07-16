local Form_RogueTalentTree = class("Form_RogueTalentTree", require("UI/UIFrames/Form_RogueTalentTreeUI"))

function Form_RogueTalentTree:SetInitParam(param)
end

function Form_RogueTalentTree:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  local resourceID = tonumber(ConfigManager:GetGlobalSettingsByKey("RogueStageTechItem"))
  local resourceIDList = {resourceID}
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot, resourceIDList)
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, nil, nil, nil, 1202)
  local initGridData = {
    itemClkBackFun = function(itemIndex, posIndex)
      self:OnTreeNodeClk(itemIndex, posIndex)
    end
  }
  self.m_luaRogueTechDetailPanel = nil
  self.m_luaTreeInfinityGrid = self:CreateInfinityGrid(self.m_scrollview_talent_InfinityGrid, "RogueChoose/UIRogueTreeItem", initGridData)
  self.m_curChooseItemIndex = nil
  self.m_curPosIndex = nil
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_showTreeNodeDataList = nil
  self:InitShowTreeNodeDataList()
end

function Form_RogueTalentTree:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI(true)
end

function Form_RogueTalentTree:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_RogueTalentTree:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RogueTalentTree:InitShowTreeNodeDataList()
  if self.m_showTreeNodeDataList then
    return
  end
  self.m_showTreeNodeDataList = self.m_levelRogueStageHelper:GetAllTechTreeList()
end

function Form_RogueTalentTree:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_csui.m_param = nil
  end
end

function Form_RogueTalentTree:ClearCacheData()
end

function Form_RogueTalentTree:GetShowTreeCfgByItemIndexAndPosIndex(itemIndex, posIndex)
  if not self.m_showTreeNodeDataList then
    return
  end
  if not itemIndex then
    return
  end
  if not posIndex then
    return
  end
  local tempLayerList = self.m_showTreeNodeDataList[itemIndex]
  if not tempLayerList then
    return
  end
  return tempLayerList[posIndex]
end

function Form_RogueTalentTree:AddEventListeners()
  self:addEventListener("eGameEvent_RogueStage_ActiveTreeNode", handler(self, self.OnActiveTreeNodeBack))
  if self.m_luaRogueTechDetailPanel then
    self.m_luaRogueTechDetailPanel:AddEventListeners()
  end
end

function Form_RogueTalentTree:RemoveAllEventListeners()
  self:clearEventListener()
  if self.m_luaRogueTechDetailPanel then
    self.m_luaRogueTechDetailPanel:RemoveAllEventListeners()
  end
end

function Form_RogueTalentTree:OnActiveTreeNodeBack(param)
  if not param then
    return
  end
  if not self.m_curChooseItemIndex then
    return
  end
  if not self.m_curPosIndex then
    return
  end
  local chooseTreeCfg = self:GetShowTreeCfgByItemIndexAndPosIndex(self.m_curChooseItemIndex, self.m_curPosIndex)
  if not chooseTreeCfg then
    return
  end
  local activeID = param.techID
  if chooseTreeCfg.m_TechID ~= activeID then
    return
  end
  self:FreshUI(false, activeID)
  self:FreshTreeNodeDetailShow()
end

function Form_RogueTalentTree:FreshUI(isNeedLocal, activeID)
  if not self.m_showTreeNodeDataList or not next(self.m_showTreeNodeDataList) then
    return
  end
  local dataList = {}
  for i, v in ipairs(self.m_showTreeNodeDataList) do
    dataList[#dataList + 1] = {cfgList = v, showFxTechID = activeID}
  end
  self.m_luaTreeInfinityGrid:ShowItemList(dataList)
  if isNeedLocal then
    local layerNum = self.m_levelRogueStageHelper:GetFirstUnlockTreeLayerNum()
    self.m_luaTreeInfinityGrid:LocateTo(layerNum - 1)
  end
  self:FreshLeftTotalNumShow()
end

function Form_RogueTalentTree:FreshLeftTotalNumShow()
  local totalNum, activeNum = self.m_levelRogueStageHelper:GetAllAndActiveTechTreeNodeNum()
  self.m_txt_total_Text.text = totalNum or 0
  self.m_txt_have_Text.text = activeNum or 0
end

function Form_RogueTalentTree:ChangeNodeChooseStatus(itemIndex, posIndex, isChoose)
  if not itemIndex then
    return
  end
  if not posIndex then
    return
  end
  local showItem = self.m_luaTreeInfinityGrid:GetShowItemByIndex(itemIndex)
  if showItem then
    showItem:ChangeChooseStatusByPosIndex(posIndex, isChoose)
  end
end

function Form_RogueTalentTree:FreshTreeNodeDetailShow()
  if self.m_curChooseItemIndex and self.m_curPosIndex then
    UILuaHelper.SetActive(self.m_root_talent, true)
    local treeCfg = self:GetShowTreeCfgByItemIndexAndPosIndex(self.m_curChooseItemIndex, self.m_curPosIndex)
    if self.m_luaRogueTechDetailPanel == nil then
      self:CreateSubPanel("RogueTechTreeDetailSubPanel", self.m_root_talent, self, {
        bgBackFun = handler(self, self.OnNodeDetailBgClick)
      }, {showTreeCfg = treeCfg}, function(luaPanel)
        self.m_luaRogueTechDetailPanel = luaPanel
        self.m_luaRogueTechDetailPanel:AddEventListeners()
      end)
    else
      self.m_luaRogueTechDetailPanel:FreshData({showTreeCfg = treeCfg})
    end
  else
    UILuaHelper.SetActive(self.m_root_talent, false)
  end
end

function Form_RogueTalentTree:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_RogueTalentTree:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_RogueTalentTree:OnTreeNodeClk(itemIndex, posIndex)
  if not itemIndex then
    return
  end
  if not posIndex then
    return
  end
  self.m_curChooseItemIndex = itemIndex
  self.m_curPosIndex = posIndex
  self:ChangeNodeChooseStatus(itemIndex, posIndex, true)
  self:FreshTreeNodeDetailShow()
end

function Form_RogueTalentTree:OnNodeDetailBgClick()
  if self.m_curChooseItemIndex then
    local tempChooseItemIndex = self.m_curChooseItemIndex
    self.m_curChooseItemIndex = nil
    local tempChoosePosIndex = self.m_curPosIndex
    self.m_curPosIndex = nil
    self:FreshTreeNodeDetailShow()
    self:ChangeNodeChooseStatus(tempChooseItemIndex, tempChoosePosIndex, false)
    GlobalManagerIns:TriggerWwiseBGMState(260)
  end
end

local fullscreen = true
ActiveLuaUI("Form_RogueTalentTree", Form_RogueTalentTree)
return Form_RogueTalentTree
