local UIItemBase = require("UI/Common/UIItemBase")
local RogueBagGridItem = class("RogueBagGridItem", UIItemBase)
local MaxQualityNum = 4
local LimitDragDis = 0.1

function RogueBagGridItem:OnInit()
  self.m_rogueDragEquipItemCom = nil
  self.m_GridX = nil
  self.m_GridY = nil
  if self.m_itemInitData then
    self.m_itemEnterDragBackFun = self.m_itemInitData.itemEnterDragBackFun
    self.m_itemDragBackFun = self.m_itemInitData.itemDragBackFun
    self.m_itemDragEndBackFun = self.m_itemInitData.itemDragEndBackFun
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_event_node_Btn_Ex = self.m_event_node:GetComponent("ButtonExtensions")
  if self.m_event_node_Btn_Ex then
    self.m_event_node_Btn_Ex.BeginDrag = handler(self, self.OnDragNodeStartDrag)
    self.m_event_node_Btn_Ex.Drag = handler(self, self.OnDragNodeDrag)
    self.m_event_node_Btn_Ex.EndDrag = handler(self, self.OnDragNodeEndDrag)
    self.m_event_node_Btn_Ex.Clicked = handler(self, self.OnItemClk)
  end
  self.m_isCanPut = true
  self.m_isPutDown = false
  self.m_isShowUp = false
end

function RogueBagGridItem:OnFreshData()
  self.m_rogueDragEquipItemCom = self.m_itemData.rogueDragEquipItemCom
  self.m_GridX = self.m_itemData.gridX
  self.m_GridY = self.m_itemData.gridY
  self:FreshGridStatus()
  self:FreshGridQuality()
end

function RogueBagGridItem:OnDestroy()
  RogueBagGridItem.super.OnDestroy(self)
end

function RogueBagGridItem:FreshGridStatus()
  local isCannotPut = not self.m_isPutDown and not self.m_isCanPut
  UILuaHelper.SetActive(self.m_img_cannot_put, isCannotPut)
  local isCanPut = not self.m_isPutDown and self.m_isCanPut
  UILuaHelper.SetActive(self.m_img_can_put, isCanPut)
  local isShowUp = self.m_isShowUp
  UILuaHelper.SetActive(self.m_img_levelup, isShowUp)
  local isShowQuality = self.m_isPutDown
  UILuaHelper.SetActive(self.m_quality_node, isShowQuality)
end

function RogueBagGridItem:ChangePutDownStatus(isPutDown)
  self.m_isPutDown = isPutDown
  self:FreshGridStatus()
end

function RogueBagGridItem:ChangeCanPutStatus(isCanPut)
  self.m_isCanPut = isCanPut
  self:FreshGridStatus()
end

function RogueBagGridItem:ChangeShowUpStatus(isShowUp)
  self.m_isShowUp = isShowUp
  self:FreshGridStatus()
end

function RogueBagGridItem:FreshGridQuality()
  if not self.m_rogueDragEquipItemCom then
    return
  end
  local qualityNum = self.m_rogueDragEquipItemCom.m_rogueEquipItemData.rogueStageItemCfg.m_Quality
  for i = 1, MaxQualityNum do
    UILuaHelper.SetActive(self["m_img_lv" .. i], i == qualityNum)
  end
end

function RogueBagGridItem:OnDragNodeStartDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
end

function RogueBagGridItem:OnDragNodeDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local dragPos = pointerEventData.position
  if self.m_isDrag then
    if self.m_itemDragBackFun then
      self.m_itemDragBackFun(dragPos)
    end
  else
    local deltaNumX = dragPos.x - self.m_startDragPos.x
    local deltaNumY = dragPos.y - self.m_startDragPos.y
    local dragDis = deltaNumX * deltaNumX + deltaNumY * deltaNumY
    if dragDis > LimitDragDis then
      if self.m_itemEnterDragBackFun then
        self.m_itemEnterDragBackFun(self.m_rogueDragEquipItemCom, dragPos)
      end
      self.m_isDrag = true
    end
  end
end

function RogueBagGridItem:OnDragNodeEndDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if self.m_itemDragEndBackFun then
    self.m_itemDragEndBackFun(pointerEventData.position)
  end
  self.m_startDragPos = nil
  self.m_isDrag = nil
end

function RogueBagGridItem:OnItemClk()
  if not self.m_rogueDragEquipItemCom then
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun()
  end
end

return RogueBagGridItem
