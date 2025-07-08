local UIItemBase = require("UI/Common/UIItemBase")
local UIRankTopTenItem = class("UIRankTopTenItem", UIItemBase)

function UIRankTopTenItem:OnInit()
  local itemTrans = self.m_itemRootObj.transform
  local c_circle_head = self.m_itemTemplateCache:GameObject("c_circle_head2")
  self.playerHeadCom = self:createPlayerHead(c_circle_head)
end

local Rank2ComTextIDEnum = {
  [1] = 100404,
  [2] = 100405,
  [3] = 100406,
  [4] = 100407,
  [5] = 100408,
  [6] = 100409,
  [7] = 100410,
  [8] = 100411,
  [9] = 100412,
  [10] = 100413
}

function UIRankTopTenItem:OnFreshData()
  local info = self.m_itemData
  local rank = info.iRank
  info.stRoleId = {
    iUid = info.iRoleUid,
    iZoneId = info.iZoneId
  }
  self.playerHeadCom:SetPlayerHeadInfo(info)
  if rank <= 3 then
    self.m_pnl_infortop:SetActive(true)
    self.m_pnl_inforother:SetActive(false)
    self.m_img_st1:SetActive(rank == 1)
    self.m_img_nd2:SetActive(rank == 2)
    self.m_img_rd3:SetActive(rank == 3)
    self.m_txt_title_Text.text = ConfigManager:GetCommonTextById(Rank2ComTextIDEnum[rank])
  else
    self.m_pnl_infortop:SetActive(false)
    self.m_pnl_inforother:SetActive(true)
    self.m_txt_titleother_Text.text = ConfigManager:GetCommonTextById(Rank2ComTextIDEnum[rank])
  end
  self.m_txt_name_Text.text = info.sName
  self.m_txt_time_Text.text = TimeUtil:TimerToString3(info.iRankValue)
end

function UIRankTopTenItem:RefreshItemFx(delay)
  self.m_itemRootObj:SetActive(false)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(delay)
  sequence:OnComplete(function()
    self.m_itemRootObj:SetActive(true)
    UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "RankListGift__listinforin")
  end)
  sequence:SetAutoKill(true)
end

return UIRankTopTenItem
