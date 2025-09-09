local BaseObject = require("Base/BaseObject")
local Singleton = require("Base/Singleton")
local meta = class("BaseNode", BaseObject, Singleton)

function meta:ctor(...)
  local params = {
    ...
  }
  self.m_bOnCreateDone = false
  self.m_bWaitLoadUIPlist = false
  self.m_bInitQueueStart = false
  self:initComponent()
  self:doEvent("OnCreateStart", ...)
  self:doEvent("OnCreate", ...)
  self:doEvent("OnCreateEnd", ...)
  self.m_bOnCreateDone = true
  self.m_luaInfinityGridList = nil
  self.m_luaInfinityGridClass = nil
  self.m_luaLoopScrollViewList = nil
  self.m_luaLoopScrollViewClass = nil
  self.m_luaCloneMulItemListList = nil
  self.m_luaCloneMulItemListClass = nil
end

function meta:initComponent()
  meta.super.initComponent(self)
  self:addComponent("GameEvent")
  self:addComponent("GameScheduler")
  self:addComponent("UIWidgetDelegate")
  self.m_initQueue = self:addComponent("UpdateQueue")
end

function meta:isInited()
  return self.m_initQueue:isFinished()
end

function meta:update(dt)
  if self.m_initQueue:isFinished() then
    self:doEvent("OnUpdate", dt)
  else
    self.m_initQueue:step()
    if self.m_initQueue:isFinished() and self.m_bInitQueueStart then
      self:doEvent("OnInitQueueFinish")
      self.m_bInitQueueStart = false
    end
  end
  self:doEvent("OnUpdateAllTime", dt)
end

function meta:CreateInfinityGrid(infinityGrid, luaPath, initGridData)
  if not self.m_luaInfinityGridClass then
    self.m_luaInfinityGridClass = require("UI/Common/UIInfinityGrid")
  end
  if not self.m_luaInfinityGridList then
    self.m_luaInfinityGridList = {}
  end
  local luaInfinityGrid = self.m_luaInfinityGridClass.new(infinityGrid, luaPath, initGridData)
  self.m_luaInfinityGridList[#self.m_luaInfinityGridList + 1] = luaInfinityGrid
  return luaInfinityGrid
end

function meta:DisposeAllInfinityGrid()
  if not self.m_luaInfinityGridList then
    return
  end
  if not next(self.m_luaInfinityGridList) then
    return
  end
  for i, v in ipairs(self.m_luaInfinityGridList) do
    v:dispose()
  end
  self.m_luaInfinityGridList = nil
end

function meta:RemoveInfinityGrid(luaInfinityGrid)
  if not luaInfinityGrid then
    return
  end
  if not self.m_luaInfinityGridList then
    return
  end
  if not next(self.m_luaInfinityGridList) then
    return
  end
  for i, v in ipairs(self.m_luaInfinityGridList) do
    if v == luaInfinityGrid then
      v:dispose()
      table.remove(self.m_luaInfinityGridList, i)
      return
    end
  end
end

function meta:CreateLoopScrollView(loopScrollView, luaPath, initGridData)
  if not loopScrollView then
    return
  end
  if not self.m_luaLoopScrollViewClass then
    self.m_luaLoopScrollViewClass = require("UI/Common/UILoopScrollView")
  end
  if not self.m_luaLoopScrollViewList then
    self.m_luaLoopScrollViewList = {}
  end
  local luaLoopScrollView = self.m_luaLoopScrollViewClass.new(loopScrollView, luaPath, initGridData)
  self.m_luaLoopScrollViewList[#self.m_luaLoopScrollViewList + 1] = luaLoopScrollView
  return luaLoopScrollView
end

function meta:DisposeAllLoopScrollView()
  if not self.m_luaLoopScrollViewList then
    return
  end
  if not next(self.m_luaLoopScrollViewList) then
    return
  end
  for i, v in ipairs(self.m_luaLoopScrollViewList) do
    v:dispose()
  end
  self.m_luaLoopScrollViewList = nil
end

function meta:RemoveLoopScrollView(luaLoopScrollView)
  if not luaLoopScrollView then
    return
  end
  if not self.m_luaLoopScrollViewList then
    return
  end
  if not next(self.m_luaLoopScrollViewList) then
    return
  end
  for i, v in ipairs(self.m_luaLoopScrollViewList) do
    if v == luaLoopScrollView then
      v:dispose()
      table.remove(self.m_luaLoopScrollViewList, i)
      return
    end
  end
end

function meta:CreateCloneMulItemList(parentNode, baseNode, luaPath, initItemData)
  if not parentNode then
    return
  end
  if not baseNode then
    return
  end
  if not self.m_luaCloneMulItemListClass then
    self.m_luaCloneMulItemListClass = require("UI/Common/UICloneMulItemList")
  end
  if not self.m_luaCloneMulItemListList then
    self.m_luaCloneMulItemListList = {}
  end
  local luaCloneMulItemList = self.m_luaCloneMulItemListClass.new(parentNode, baseNode, luaPath, initItemData)
  self.m_luaCloneMulItemListList[#self.m_luaCloneMulItemListList + 1] = luaCloneMulItemList
  return luaCloneMulItemList
end

function meta:DisposeAllCloneMulItemList()
  if not self.m_luaCloneMulItemListList then
    return
  end
  if not next(self.m_luaCloneMulItemListList) then
    return
  end
  for i, v in ipairs(self.m_luaCloneMulItemListList) do
    v:dispose()
  end
  self.m_luaCloneMulItemListList = nil
end

function meta:RemoveCloneMulItemList(luaCloneMulItemList)
  if not luaCloneMulItemList then
    return
  end
  if not self.m_luaCloneMulItemListList then
    return
  end
  if not next(self.m_luaCloneMulItemListList) then
    return
  end
  for i, v in ipairs(self.m_luaCloneMulItemListList) do
    if v == luaCloneMulItemList then
      v:dispose()
      table.remove(self.m_luaCloneMulItemListList, i)
      return
    end
  end
end

function meta:pause()
  local function doPause()
    self:doEvent("OnPause")
  end
  
  if self.m_initQueue:isFinished() then
    doPause()
  else
    self.m_initQueue:add(doPause)
  end
end

function meta:resume()
  local function doResume()
    self:doEvent("OnResume")
  end
  
  if self.m_initQueue:isFinished() then
    doResume()
  else
    self.m_initQueue:add(doResume)
  end
end

function meta:resumeEnd()
  local function doResumeEnd()
    self:doEvent("OnResumeEnd")
  end
  
  if self.m_initQueue:isFinished() then
    doResumeEnd()
  else
    self.m_initQueue:add(doResumeEnd)
  end
end

function meta:dispose()
  if not self._disposed then
    self._disposed = true
    self:removeAllComponent()
    self:DisposeAllInfinityGrid()
    self:DisposeAllCloneMulItemList()
    self:DisposeAllLoopScrollView()
    if self.m_bOnCreateDone then
      self:doEvent("OnDestroy")
    end
    if self:isInstance() then
      self:clearInstance()
    end
  end
end

return meta
