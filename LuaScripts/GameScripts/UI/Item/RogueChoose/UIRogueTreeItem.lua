local UIItemBase = require("UI/Common/UIItemBase")
local UIRogueTreeItem = class("UIRogueTreeItem", UIItemBase)
local UIRogueTreeNodeItem = require("UI/Item/RogueChoose/UIRogueTreeNodeItem")
local MaxNodeNum = 4
local SmallScaleNum = 0.75
local TechShowType = {BigNode = 1, NormalNode = 2}
local RotationCenterX = -880
local RotationCenterY = 0
local RadiusNum = 880
local RotationMaxNum = 20.3
local RotationMinNum = -20.3

function UIRogueTreeItem:OnInit()
  self.m_item_mul_root_trans = self.m_item_mul_root.transform
  if self.m_itemInitData then
    self.m_itemNodeClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.m_treeItemData = nil
  self.m_oneBigTreeNode = nil
  self.m_mulTreeNodeList = nil
  self:InitCreateAllTreeNodeCom()
end

function UIRogueTreeItem:OnFreshData()
  self.m_treeItemData = self.m_itemData.cfgList
  self.m_showFxTechID = self.m_itemData.showFxTechID
  if not self.m_treeItemData then
    return
  end
  self:FreshItemUI()
end

function UIRogueTreeItem:GetUpDownActTopIndex()
  if not self.m_treeItemData then
    return
  end
  if not next(self.m_treeItemData) then
    return
  end
  local isOneBigNode = self.m_treeItemData[1].m_TechShowType == TechShowType.BigNode
  if isOneBigNode then
    return
  end
  local maxTreeNodeNum = #self.m_treeItemData
  if maxTreeNodeNum == 1 then
    return
  end
  local isEvenNum = maxTreeNodeNum % 2
  local upActIndex = -1
  local downActIndex = -1
  if isEvenNum then
    local midNum = math.floor(maxTreeNodeNum / 2)
    for i = 1, maxTreeNodeNum do
      local isActive = self.m_levelRogueStageHelper:IsTechNodeActive(self.m_treeItemData[i].m_TechID)
      if isActive == true then
        if i <= midNum then
          if upActIndex == -1 or i < upActIndex then
            upActIndex = i
          end
        elseif downActIndex == -1 or i > downActIndex then
          downActIndex = i
        end
      end
    end
  else
    local midNum = math.floor(maxTreeNodeNum / 2) + 1
    for i = 1, maxTreeNodeNum do
      local isActive = self.m_levelRogueStageHelper:IsTechNodeActive(self.m_treeItemData[i].m_TechID)
      if isActive == true then
        if i < midNum then
          if upActIndex == -1 or i < upActIndex then
            upActIndex = i
          end
        elseif downActIndex == -1 or i > downActIndex then
          downActIndex = i
        end
      end
    end
  end
  return upActIndex, downActIndex
end

function UIRogueTreeItem:InitCreateAllTreeNodeCom()
  local initItemData = {
    posIndex = 1,
    itemClkBackFun = function(posIndex)
      self:OnTreeNodeClk(posIndex)
    end
  }
  local rogueTreeNodeItemCom = UIRogueTreeNodeItem.new(nil, self.m_rogue_talent_item, initItemData, nil, 1)
  self.m_oneBigTreeNode = rogueTreeNodeItemCom
  self.m_mulTreeNodeList = {}
  for i = 1, MaxNodeNum do
    local gameObject = GameObject.Instantiate(self.m_rogue_talent_item, self.m_item_mul_root_trans).gameObject
    UILuaHelper.SetLocalScale(gameObject, SmallScaleNum, SmallScaleNum, 1)
    initItemData = {
      posIndex = i,
      itemClkBackFun = function(posIndex)
        self:OnTreeNodeClk(posIndex)
      end
    }
    rogueTreeNodeItemCom = UIRogueTreeNodeItem.new(nil, gameObject, initItemData, nil, i)
    self.m_mulTreeNodeList[#self.m_mulTreeNodeList + 1] = rogueTreeNodeItemCom
  end
end

function UIRogueTreeItem:FreshItemUI()
  if not self.m_treeItemData then
    return
  end
  self:FreshHorizontalLineShow()
  self:FreshTreeNodeShow()
  self:FreshUpDownLineShow()
end

function UIRogueTreeItem:FreshHorizontalLineShow()
  if not self.m_treeItemData then
    return
  end
  local isLeftAct = self.m_levelRogueStageHelper:IsTechTreeLayerActive(self.m_itemIndex) == true
  UILuaHelper.SetActive(self.m_img_line_light_left, isLeftAct)
  local isOverMax = self.m_levelRogueStageHelper:IsTechTreeOverMax(self.m_itemIndex + 1)
  UILuaHelper.SetActive(self.m_img_line_right, isOverMax ~= true)
  if isOverMax ~= true then
    local isRightAct = self.m_levelRogueStageHelper:IsTechTreeLayerActive(self.m_itemIndex + 1) == true
    UILuaHelper.SetActive(self.m_img_line_light_right, isRightAct)
  end
end

function UIRogueTreeItem:FreshTreeNodeShow()
  if not self.m_treeItemData then
    return
  end
  if not next(self.m_treeItemData) then
    return
  end
  local isOneBigNode = self.m_treeItemData[1].m_TechShowType == TechShowType.BigNode
  UILuaHelper.SetActive(self.m_item_one_root, isOneBigNode)
  UILuaHelper.SetActive(self.m_item_mul_root, not isOneBigNode)
  if isOneBigNode then
    if self.m_oneBigTreeNode then
      self.m_oneBigTreeNode:FreshItemShow(self.m_treeItemData[1])
    end
  else
    local maxTreeNodeNum = #self.m_treeItemData
    for i = 1, MaxNodeNum do
      local tempTreeCfg = self.m_treeItemData[i]
      local itemRootObj = self.m_mulTreeNodeList[i].m_itemRootObj
      UILuaHelper.SetActive(itemRootObj, tempTreeCfg ~= nil)
      if tempTreeCfg then
        self.m_mulTreeNodeList[i]:FreshItemShow(tempTreeCfg, self.m_showFxTechID)
        if maxTreeNodeNum == 1 then
          UILuaHelper.SetLocalPosition(itemRootObj, 0, 0, 0)
        else
          local rotationNum = (RotationMaxNum - RotationMinNum) * ((maxTreeNodeNum - i) / (maxTreeNodeNum - 1)) + RotationMinNum
          local localPosX = RadiusNum * math.cos(math.rad(rotationNum)) + RotationCenterX
          local localPosY = RadiusNum * math.sin(math.rad(rotationNum)) + RotationCenterY
          UILuaHelper.SetLocalPosition(itemRootObj, localPosX, localPosY, 0)
        end
      end
    end
  end
end

function UIRogueTreeItem:FreshUpDownLineShow()
  if not self.m_treeItemData then
    return
  end
  if not next(self.m_treeItemData) then
    return
  end
  local isOneBigNode = self.m_treeItemData[1].m_TechShowType == TechShowType.BigNode
  if isOneBigNode then
    return
  end
  local maxTreeNodeNum = #self.m_treeItemData
  if maxTreeNodeNum == 1 then
    UILuaHelper.SetActive(self.m_up_down_line, false)
    return
  end
  UILuaHelper.SetActive(self.m_up_down_line, true)
  local upIndex, downIndex = self:GetUpDownActTopIndex()
  if upIndex == nil or upIndex == -1 then
    self.m_img_line_light_up_Image.fillAmount = 0
  else
    local upRotationNum = (RotationMaxNum - RotationMinNum) * ((maxTreeNodeNum - upIndex) / (maxTreeNodeNum - 1)) + RotationMinNum
    if 0 <= upRotationNum then
      self.m_img_line_light_up_Image.fillAmount = upRotationNum / RotationMaxNum
    else
      self.m_img_line_light_up_Image.fillAmount = 0
    end
  end
  if downIndex == nil or downIndex == -1 then
    self.m_img_line_light_down_Image.fillAmount = 0
  else
    local downRotationNum = (RotationMaxNum - RotationMinNum) * ((maxTreeNodeNum - downIndex) / (maxTreeNodeNum - 1)) + RotationMinNum
    if downRotationNum <= 0 then
      self.m_img_line_light_down_Image.fillAmount = downRotationNum / RotationMinNum
    else
      self.m_img_line_light_down_Image.fillAmount = 0
    end
  end
end

function UIRogueTreeItem:ChangeChooseStatusByPosIndex(posIndex, isChoose)
  if not posIndex then
    return
  end
  if not self.m_treeItemData then
    return
  end
  local tempTreeCfg = self.m_treeItemData[posIndex]
  if not tempTreeCfg then
    return
  end
  if tempTreeCfg.m_TechShowType == TechShowType.BigNode then
    self.m_oneBigTreeNode:ChangeChooseStatus(isChoose)
  else
    local treeNode = self.m_mulTreeNodeList[posIndex]
    if treeNode then
      treeNode:ChangeChooseStatus(isChoose)
    end
  end
end

function UIRogueTreeItem:OnTreeNodeClk(posIndex)
  if not posIndex then
    return
  end
  if self.m_itemNodeClkBackFun then
    self.m_itemNodeClkBackFun(self.m_itemIndex, posIndex)
  end
end

return UIRogueTreeItem
