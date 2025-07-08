local UIItemBase = require("UI/Common/UIItemBase")
local UIRogueTreeNodeItem = class("UIRogueTreeNodeItem", UIItemBase)

function UIRogueTreeNodeItem:OnInit()
  if self.m_itemInitData then
    self.m_posIndex = self.m_itemInitData.posIndex
    self.m_itemNodeClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_circleIcon = self.m_circle_img_icon:GetComponent("CircleImage")
  self.m_treeNodeItemData = nil
  self.m_ShowAnimFlag = true
end

function UIRogueTreeNodeItem:OnFreshData()
end

function UIRogueTreeNodeItem:FreshItemShow(treeNodeData, showFxTechID)
  if not treeNodeData then
    return
  end
  self.m_treeNodeItemData = treeNodeData
  self:FreshItemUI()
  self.m_roguetalenttree_unlock:SetActive(false)
  if showFxTechID == treeNodeData.m_TechID and self.m_ShowAnimFlag then
    self.m_roguetalenttree_unlock:SetActive(true)
    self.m_ShowAnimFlag = false
    GlobalManagerIns:TriggerWwiseBGMState(110)
  else
    self.m_roguetalenttree_unlock:SetActive(false)
  end
end

function UIRogueTreeNodeItem:ChangeChooseStatus(isChoose)
  if not self.m_treeNodeItemData then
    return
  end
  UILuaHelper.SetActive(self.m_node_sel, isChoose)
end

function UIRogueTreeNodeItem:FreshItemUI()
  if not self.m_treeNodeItemData then
    return
  end
  UILuaHelper.SetBaseImageAtlasSprite(self.m_circleIcon, self.m_treeNodeItemData.m_TechPic)
  self:FreshStatus()
  self:ChangeChooseStatus(false)
end

function UIRogueTreeNodeItem:FreshStatus()
  if not self.m_treeNodeItemData then
    return
  end
  UILuaHelper.SetBaseImageAtlasSprite(self.m_circleIcon, self.m_treeNodeItemData.m_TechPic)
  local techID = self.m_treeNodeItemData.m_TechID
  local isActive = self.m_levelRogueStageHelper:IsTechNodeActive(techID)
  local isCanActive, _ = self.m_levelRogueStageHelper:IsTechNodeCanActive(techID)
  UILuaHelper.SetActive(self.m_node_normal, isActive)
  UILuaHelper.SetActive(self.m_node_can_active, not isActive and isCanActive)
  UILuaHelper.SetActive(self.m_node_lock, not isActive)
  UILuaHelper.SetActive(self.m_roguetalenttree_loop, not isActive and isCanActive)
end

function UIRogueTreeNodeItem:OnBtnTreeNodeClicked()
  if not self.m_treeNodeItemData then
    return
  end
  if self.m_itemNodeClkBackFun then
    self.m_itemNodeClkBackFun(self.m_posIndex)
  end
end

return UIRogueTreeNodeItem
