local UIItemBase = require("UI/Common/UIItemBase")
local UIDispatchRateItem = class("UIDispatchRateItem", UIItemBase)
local __HERO_MAX = 5

function UIDispatchRateItem:OnInit()
  self.m_common_item = self.m_itemRootObj.transform:Find("c_common_item").gameObject
  self.m_txt_probabilitynum_Text = self.m_itemRootObj.transform:Find("c_txt_probabilitynum"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_incident_star_num_Text = self.m_itemRootObj.transform:Find("icon_star/c_txt_incident_star_num"):GetComponent(T_TextMeshProUGUI)
  self.m_txt_time_Text = self.m_itemRootObj.transform:Find("c_txt_time_down"):GetComponent(T_TextMeshProUGUI)
  self.m_scrollViewContent = self.m_itemRootObj.transform:Find("c_hero_list"):GetComponent("ScrollRect").content
  self.m_hero_itemTemplate = self.m_itemRootObj.transform:Find("c_hero_list"):GetComponent("ScrollRect").content.transform:Find("c_hero_item").gameObject
  self.m_hero_itemTemplate:SetActive(false)
  self.m_ObjList = {}
  for i = 1, __HERO_MAX do
    local cloneObj = ResourceUtil:CreateItem(self.m_hero_itemTemplate, self.m_scrollViewContent)
    local gradeImg = cloneObj.transform:Find("c_icon_hero_item_grade"):GetComponent(T_Image)
    self.m_ObjList[#self.m_ObjList + 1] = {obj = cloneObj, gradeImg = gradeImg}
  end
end

function UIDispatchRateItem:OnFreshData()
  if self.m_widgetItemIconReward == nil then
    self.m_widgetItemIconReward = self:createCommonItem(self.m_common_item)
    self.m_widgetItemIconReward:SetItemIconClickCB(handler(self, self.OnItemClick))
  end
  local eventCfg = self.m_itemData.cfg
  local rewardData = utils.changeCSArrayToLuaTable(eventCfg.m_Reward)[1]
  local processData = ResourceUtil:GetProcessRewardData(rewardData)
  self.m_widgetItemIconReward:SetItemInfo(processData)
  self.m_txt_incident_star_num_Text.text = eventCfg.m_Grade
  self.m_txt_probabilitynum_Text.text = string.format(ConfigManager:GetCommonTextById(100009), string.format("%.2f", self.m_itemData.rate))
  self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(eventCfg.m_TimeMin * 60)
  local slot = utils.changeCSArrayToLuaTable(eventCfg.m_Slot)
  for i = 1, __HERO_MAX do
    if slot[i] and self.m_ObjList[i] then
      self.m_ObjList[i].obj:SetActive(true)
      ResourceUtil:CreateQualityImg(self.m_ObjList[i].gradeImg, slot[i][2])
    else
      self.m_ObjList[i].obj:SetActive(false)
    end
  end
end

function UIDispatchRateItem:OnItemClick(index, itemObj)
  local itemData = self.m_itemData
  if itemData then
    local eventCfg = itemData.cfg
    local rewardData = utils.changeCSArrayToLuaTable(eventCfg.m_Reward)[1]
    utils.openItemDetailPop({
      iID = rewardData[1],
      iNum = rewardData[2]
    })
  end
end

function UIDispatchRateItem:dispose()
  UIDispatchRateItem.super.dispose(self)
  if self.m_ObjList then
    for i = #self.m_ObjList, 1, -1 do
      if self.m_ObjList[i].obj and not utils.isNull(self.m_ObjList[i].obj) then
        GameObject.Destroy(self.m_ObjList[i].obj)
        self.m_ObjList[i] = nil
      end
    end
  end
end

return UIDispatchRateItem
