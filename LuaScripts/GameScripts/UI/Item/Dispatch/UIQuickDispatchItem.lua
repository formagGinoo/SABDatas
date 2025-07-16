local UIItemBase = require("UI/Common/UIItemBase")
local UIQuickDispatchItem = class("UIQuickDispatchItem", UIItemBase)

function UIQuickDispatchItem:OnInit()
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick)
  }
  self.m_hero_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_hero_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_hero_listInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnItemClick))
end

function UIQuickDispatchItem:OnFreshData()
  self.m_heroList = self.m_itemData.heroTab
  local event = self.m_itemData.event
  local cfg = CastleDispatchManager:GetCastleDispatchEventCfg(event.iGroupId, event.iEventId)
  local lv = CastleDispatchManager:GetDispatchLevel()
  local lvCfg = CastleDispatchManager:GetCastleDispatchLevelCfg(lv)
  local locationCfg = CastleDispatchManager:GetCastleDispatchLocationCfg(self.m_itemData.index)
  if cfg and lvCfg and locationCfg then
    self.m_bg_sp:SetActive(lvCfg.m_SpecialStar >= cfg.m_Grade)
    self.m_txt_incident_star_num_receive_Text.text = cfg.m_Grade
    self.m_txt_title_Text.text = locationCfg.m_mDispatchLocation
    local rewardData = utils.changeCSArrayToLuaTable(cfg.m_Reward)[1]
    local processData = ResourceUtil:GetProcessRewardData({
      iID = rewardData[1],
      iNum = rewardData[2]
    })
    UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, processData.icon_name, nil, nil, true)
    self.m_txt_item_num_Text.text = rewardData[2]
  end
  self.m_img_icon:SetActive(self.m_itemData.isSelected)
  local dataList = {}
  for i, v in ipairs(self.m_heroList) do
    local processData = ResourceUtil:GetProcessRewardData({iID = v})
    dataList[#dataList + 1] = processData
  end
  self.m_hero_listInfinityGrid:ShowItemList(dataList)
end

function UIQuickDispatchItem:OnItemClick(index, itemObj)
  local heroId = self.m_heroList[index + 1]
  local heroData = HeroManager:GetHeroDataByID(heroId)
  if heroId and heroData then
    utils.openItemDetailPop({
      iID = heroId,
      heroServerData = heroData.serverData
    })
  end
end

function UIQuickDispatchItem:dispose()
  UIQuickDispatchItem.super.dispose(self)
end

return UIQuickDispatchItem
