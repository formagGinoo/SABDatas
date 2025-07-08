local UIItemBase = require("UI/Common/UIItemBase")
local UIRankTargetListItem = class("UIRankTargetListItem", UIItemBase)

function UIRankTargetListItem:OnInit()
  self.m_PrefabHelper = self.m_reward_root:GetComponent("PrefabHelper")
  self.m_PrefabHelper:RegisterCallback(handler(self, self.OnInitRewardItem))
  local c_circle_head = self.m_itemTemplateCache:GameObject("c_circle_head")
  self.playerHeadCom = self:createPlayerHead(c_circle_head)
end

function UIRankTargetListItem:OnFreshData()
  local cfg = self.m_itemData.cfg
  local topRole = self.m_itemData.topRole
  if topRole then
    topRole.stRoleId = {
      iUid = topRole.iRoleUid,
      iZoneId = topRole.iZoneId
    }
    self.playerHeadCom:SetPlayerHeadInfo(topRole)
  end
  self.m_txt_titletask_Text.text = cfg.m_mTargerDesc
  self.reward_array = utils.changeCSArrayToLuaTable(cfg.m_TargetReward)
  self.m_PrefabHelper:CheckAndCreateObjs(#self.reward_array)
  self.m_btn_receive:SetActive(self.m_itemData.state == 0)
  self.m_pnl_unfinish:SetActive(self.m_itemData.state == 1)
  self.m_img_complete:SetActive(self.m_itemData.state == 2)
  if topRole then
    self.m_pnl_haveinfor:SetActive(true)
    self.m_pnl_ranknone:SetActive(false)
    self.m_txt_name_Text.text = topRole.sName
    self.m_txt_time_Text.text = TimeUtil:TimerToString3(topRole.iRankValue)
  else
    self.m_pnl_haveinfor:SetActive(false)
    self.m_pnl_ranknone:SetActive(true)
  end
  self.m_img_selout:SetActive(self.m_itemData.isSelect)
end

function UIRankTargetListItem:OnInitRewardItem(go, index)
  index = index + 1
  local data = self.reward_array[index]
  local reward_item = self:createCommonItem(go)
  local processData = ResourceUtil:GetProcessRewardData({
    iID = data[1],
    iNum = data[2]
  })
  reward_item:SetItemInfo(processData)
  reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end)
  reward_item:SetItemHaveGetActive(self.m_itemData.state == 2)
end

function UIRankTargetListItem:RefreshItemFx(delay)
  UILuaHelper.SetCanvasGroupAlpha(self.m_itemRootObj, 0)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(delay)
  sequence:OnComplete(function()
    UILuaHelper.SetCanvasGroupAlpha(self.m_itemRootObj, 1)
    UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "RankListGift_cellin")
  end)
  sequence:SetAutoKill(true)
end

function UIRankTargetListItem:OnBtnreceiveClicked()
  local cfg = self.m_itemData.cfg
  local _, list = GlobalRankManager:IsGlobalRankTargetCanRec({
    cfg.m_RankID
  })
  GlobalRankManager:RqsRankDrawTargetReward(cfg.m_RankID, list)
end

function UIRankTargetListItem:OnButtoncheckClicked()
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

return UIRankTargetListItem
