local UIItemBase = require("UI/Common/UIItemBase")
local UIPartDungeonWelfareRewardItem = class("UIPartDungeonWelfareRewardItem", UIItemBase)

function UIPartDungeonWelfareRewardItem:OnInit()
  if self.m_itemInitData then
    self.OnItemClk = self.m_itemInitData.OnItemClk
  end
  self.commonItem = self.m_itemRootObj.transform:Find("c_common_item")
  self.beClaimedNode = self.commonItem:Find("c_uieff_receive")
end

function UIPartDungeonWelfareRewardItem:OnFreshData()
  local itemWidget = self:createCommonItem(self.commonItem.gameObject)
  
  local function callBack(itemID, itemNum, itemCom)
    if not itemID then
      return
    end
    utils.openItemDetailPop({iID = itemID, iNum = itemNum})
  end
  
  if self.m_itemData.beClaimed then
    function callBack()
      self.OnItemClk(self.m_itemData.score)
    end
  end
  itemWidget:SetItemIconClickCB(callBack)
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_itemData.id,
    iNum = self.m_itemData.num
  }, {
    is_have_get = self.m_itemData.isHaveGet
  })
  itemWidget:SetItemInfo(processItemData)
  if self.beClaimedNode then
    UILuaHelper.SetActive(self.beClaimedNode.gameObject, self.m_itemData.beClaimed)
  end
  UILuaHelper.SetActive(self.m_light_line, self.m_itemData.isShowLight)
  UILuaHelper.SetActive(self.m_light_point, self.m_itemData.isShowPoint)
  UILuaHelper.SetActive(self.m_normal_line, self.m_itemData.isLast)
  self.m_reward_num_Text.text = BigNumFormat(self.m_itemData.score)
end

return UIPartDungeonWelfareRewardItem
