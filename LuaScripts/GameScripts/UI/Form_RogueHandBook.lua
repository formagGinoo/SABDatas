local Form_RogueHandBook = class("Form_RogueHandBook", require("UI/UIFrames/Form_RogueHandBookUI"))
local RogueHandBookItemState = {
  Active = 1,
  UnActive = 2,
  Locked = 3
}
local __RogueHandBook_itemin = "RogueHandBook_itemin"

function Form_RogueHandBook:SetInitParam(param)
end

function Form_RogueHandBook:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1204)
  self.m_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_handbook_InfinityGrid, "RogueChoose/RogueHandBookItem")
  self:RegisterOrUpdateRedDotItem(self.m_exclusive_new, RedDotDefine.ModuleType.RogueHandBookTabRedDot, RogueStageManager.HandBookType.Exclusive)
  self:RegisterOrUpdateRedDotItem(self.m_common_new, RedDotDefine.ModuleType.RogueHandBookTabRedDot, RogueStageManager.HandBookType.Normal)
  self:RegisterOrUpdateRedDotItem(self.m_material_new, RedDotDefine.ModuleType.RogueHandBookTabRedDot, RogueStageManager.HandBookType.Material)
end

function Form_RogueHandBook:OnActive()
  self.super.OnActive(self)
  self.vClearNewMarkTab = {}
  self.iCurTabIdx = RogueStageManager.HandBookType.Exclusive
  self:FreshUI()
  self:PlayerEnterAnim()
end

function Form_RogueHandBook:OnInactive()
  self.super.OnInactive(self)
  if self.m_sequence then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
  self:ClearNewMark()
end

function Form_RogueHandBook:PlayerEnterAnim()
  if self.m_sequence then
    self.m_sequence:Kill()
    self.m_sequence = nil
  end
  self.m_sequence = Tweening.DOTween.Sequence()
  self.m_sequence:AppendInterval(0.255)
  self.m_sequence:OnComplete(function()
    self:PlayerAnim()
  end)
  self.m_sequence:SetAutoKill(true)
end

function Form_RogueHandBook:PlayerAnim()
  UILuaHelper.ResetAnimationByName(self.m_Content, __RogueHandBook_itemin)
  UILuaHelper.PlayAnimationByName(self.m_Content, __RogueHandBook_itemin)
end

function Form_RogueHandBook:OnDestroy()
  self.super.OnDestroy(self)
  self:UnRegisterAllRedDotItem()
  self.m_InfinityGrid:dispose()
end

function Form_RogueHandBook:ClearNewMark()
  local m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  local HandBookCfgs = m_levelRogueStageHelper:GetRogueHandBookCfgs()
  if not HandBookCfgs then
    return
  end
  for k, v in pairs(self.vClearNewMarkTab) do
    local cfgs = HandBookCfgs[v]
    if cfgs then
      for i, vv in ipairs(cfgs) do
        if vv.iState == RogueHandBookItemState.Active then
          local cfg = vv.cfg
          local localValue = LocalDataManager:GetIntSimple("RogueHandBookItem_ID_" .. cfg.m_ItemID, 0)
          if localValue == 0 then
            LocalDataManager:SetIntSimple("RogueHandBookItem_ID_" .. cfg.m_ItemID, 1, true)
          end
        end
      end
    end
  end
  self:broadcastEvent("eGameEvent_RogueHandBookItem_StateChange")
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.RogueHandBookEntry,
    count = self.m_levelRogueStageHelper:CheckRogueHandBookEntryReddot()
  })
end

function Form_RogueHandBook:FreshUI()
  local m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  local HandBookCfgs = m_levelRogueStageHelper:GetRogueHandBookCfgs()
  if not HandBookCfgs then
    return
  end
  local cfgs = HandBookCfgs[self.iCurTabIdx]
  if not cfgs then
    return
  end
  self.vClearNewMarkTab[#self.vClearNewMarkTab + 1] = self.iCurTabIdx
  for i, v in ipairs(cfgs) do
    local cfg = v.cfg
    self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
    local serverData = self.m_levelRogueStageHelper:GetRogueServerData()
    v.iState = nil
    if not serverData then
      v.iState = RogueHandBookItemState.Locked
    else
      local iLimitTechID = cfg.m_TechID
      local mTech = serverData.mTech
      if mTech and 0 < iLimitTechID and (mTech[iLimitTechID] == nil or mTech[iLimitTechID] == 0) then
        v.iState = RogueHandBookItemState.Locked
      end
      local mHandbook = serverData.mHandbook
      if mHandbook and not v.iState then
        v.iState = mHandbook[cfg.m_ItemID] ~= nil and 0 < mHandbook[cfg.m_ItemID] and RogueHandBookItemState.Active or RogueHandBookItemState.UnActive
      end
    end
    if v.iState == 0 then
      v.iState = RogueHandBookItemState.Locked
    end
  end
  table.sort(cfgs, function(a, b)
    if a.iState ~= b.iState then
      return a.iState < b.iState
    end
    return a.cfg.m_HandbookOrder < b.cfg.m_HandbookOrder
  end)
  self.m_InfinityGrid:ShowItemList(cfgs)
  self.m_InfinityGrid:LocateTo(0)
  self:FreshTab()
end

function Form_RogueHandBook:FreshTab()
  if self.iCurTabIdx == RogueStageManager.HandBookType.Exclusive then
    self.m_pnl_select:SetActive(true)
    self.m_pnl_common:SetActive(false)
    self.m_pnl_material:SetActive(false)
    self.m_pnl_exclusive_unselect:SetActive(false)
    self.m_pnl_common_unselect:SetActive(true)
    self.m_pnl_material_unselect:SetActive(true)
  elseif self.iCurTabIdx == RogueStageManager.HandBookType.Normal then
    self.m_pnl_select:SetActive(false)
    self.m_pnl_common:SetActive(true)
    self.m_pnl_material:SetActive(false)
    self.m_pnl_exclusive_unselect:SetActive(true)
    self.m_pnl_common_unselect:SetActive(false)
    self.m_pnl_material_unselect:SetActive(true)
  elseif self.iCurTabIdx == RogueStageManager.HandBookType.Material then
    self.m_pnl_select:SetActive(false)
    self.m_pnl_common:SetActive(false)
    self.m_pnl_material:SetActive(true)
    self.m_pnl_exclusive_unselect:SetActive(true)
    self.m_pnl_common_unselect:SetActive(true)
    self.m_pnl_material_unselect:SetActive(false)
  end
end

function Form_RogueHandBook:OnPnltabexclusiveClicked()
  if self.iCurTabIdx == RogueStageManager.HandBookType.Exclusive then
    return
  end
  self.iCurTabIdx = RogueStageManager.HandBookType.Exclusive
  self:FreshUI()
  self:PlayerAnim()
  GlobalManagerIns:TriggerWwiseBGMState(62)
end

function Form_RogueHandBook:OnPnltabcommonClicked()
  if self.iCurTabIdx == RogueStageManager.HandBookType.Normal then
    return
  end
  self.iCurTabIdx = RogueStageManager.HandBookType.Normal
  self:FreshUI()
  self:PlayerAnim()
  GlobalManagerIns:TriggerWwiseBGMState(62)
end

function Form_RogueHandBook:OnPnltabmaterialClicked()
  if self.iCurTabIdx == RogueStageManager.HandBookType.Material then
    return
  end
  self.iCurTabIdx = RogueStageManager.HandBookType.Material
  self:FreshUI()
  self:PlayerAnim()
  GlobalManagerIns:TriggerWwiseBGMState(62)
end

function Form_RogueHandBook:OnBackClk()
  self:CloseForm()
end

function Form_RogueHandBook:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RogueHandBook", Form_RogueHandBook)
return Form_RogueHandBook
