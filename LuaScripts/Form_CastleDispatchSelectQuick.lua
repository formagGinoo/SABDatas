local Form_CastleDispatchSelectQuick = class("Form_CastleDispatchSelectQuick", require("UI/UIFrames/Form_CastleDispatchSelectQuickUI"))

function Form_CastleDispatchSelectQuick:SetInitParam(param)
end

function Form_CastleDispatchSelectQuick:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_dispatch_list_InfinityGrid, "Dispatch/UIQuickDispatchItem", initGridData)
  self.m_listInfinityGrid:RegisterButtonCallback("c_img_finish", handler(self, self.OnItemClk))
  self.m_listInfinityGrid:RegisterButtonCallback("c_reward_btn", handler(self, self.OnRewardItemClk))
  self.m_btnExtension = self.m_dispatch_list:GetComponent("ButtonExtensions")
  if self.m_btnExtension then
    self.m_btnExtension.BeginDrag = handler(self, self.OnRectBeginDrag)
  end
end

function Form_CastleDispatchSelectQuick:OnActive()
  self.super.OnActive(self)
  self:RefreshUI()
  self:AddEventListeners()
  self:ShowItemListAnim()
  if self.m_listInfinityGrid then
    self.m_listInfinityGrid:LocateTo(0)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(202)
end

function Form_CastleDispatchSelectQuick:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_CastleDispatchSelectQuick:AddEventListeners()
  self:addEventListener("eGameEvent_CastleDoDispatch", handler(self, self.QuickDispatchCallBack))
  self:addEventListener("eGameEvent_CastleDispatchRefresh", handler(self, self.OnBtncancelClicked))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtncancelClicked))
end

function Form_CastleDispatchSelectQuick:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_CastleDispatchSelectQuick:RefreshUI()
  self.m_dispatchList = CastleDispatchManager:QuicklyDispatch()
  self.m_listInfinityGrid:ShowItemList(self.m_dispatchList)
end

function Form_CastleDispatchSelectQuick:ShowItemListAnim()
  local showItemList = self.m_listInfinityGrid:GetAllShownItemList()
  for i, tempItem in ipairs(showItemList) do
    local tempObj = tempItem:GetItemRootObj()
    local sequence = Tweening.DOTween.Sequence()
    sequence:AppendInterval(0.1 * (i - 1))
    sequence:OnComplete(function()
      if not utils.isNull(tempObj) then
        UILuaHelper.PlayAnimationByName(tempObj, "c_pnl_item_in")
      end
    end)
    sequence:SetAutoKill(true)
  end
end

function Form_CastleDispatchSelectQuick:OnItemClk(idx)
  local index = idx + 1
  if not self.m_dispatchList[index] then
    return
  end
  self.m_dispatchList[index].isSelected = not self.m_dispatchList[index].isSelected
  self.m_listInfinityGrid:ReBind(index)
end

function Form_CastleDispatchSelectQuick:OnRewardItemClk(idx)
  local index = idx + 1
  if not self.m_dispatchList[index] or not self.m_dispatchList[index].event then
    return
  end
  local event = self.m_dispatchList[index].event
  local cfg = CastleDispatchManager:GetCastleDispatchEventCfg(event.iGroupId, event.iEventId)
  if cfg then
    local rewardData = utils.changeCSArrayToLuaTable(cfg.m_Reward)[1]
    utils.openItemDetailPop({
      iID = rewardData[1],
      iNum = rewardData[2]
    })
  end
end

function Form_CastleDispatchSelectQuick:OnBtndispatchClicked()
  local mLocationHero = {}
  for i, v in pairs(self.m_dispatchList) do
    if v.isSelected then
      mLocationHero[v.index] = v.heroTab
    end
  end
  CastleDispatchManager:ReqCastleDoDispatch(mLocationHero)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(205)
end

function Form_CastleDispatchSelectQuick:QuickDispatchCallBack()
  self:OnBtncancelClicked()
  StackPopup:Push(UIDefines.ID_FORM_CASTLEDISPATCHSTART)
end

function Form_CastleDispatchSelectQuick:IsOpenGuassianBlur()
  return true
end

function Form_CastleDispatchSelectQuick:OnBtncancelClicked()
  self:CloseForm()
end

function Form_CastleDispatchSelectQuick:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleDispatchSelectQuick:OnRectBeginDrag()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(203)
end

local fullscreen = true
ActiveLuaUI("Form_CastleDispatchSelectQuick", Form_CastleDispatchSelectQuick)
return Form_CastleDispatchSelectQuick
