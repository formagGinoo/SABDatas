local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroAct103DailyTaskRewardItem = class("UIHeroAct103DailyTaskRewardItem", UIItemBase)

function UIHeroAct103DailyTaskRewardItem:OnInit()
  self.prefabHelper = self.m_reward_nodeday:GetComponent("PrefabHelper")
end

function UIHeroAct103DailyTaskRewardItem:OnFreshData()
  local str = self.m_itemIndex > 9 and self.m_itemIndex or "0" .. self.m_itemIndex
  self.m_txt_tasknum_Text.text = str
  local cfg = self.m_itemData.cfg
  local iActId = self.m_itemData.iActId
  local serverData = HeroActivityManager:GetActTaskServerData(iActId)
  local iCurScore = serverData and serverData.iDaiyQuestActive or 0
  local preCfg = HeroActivityManager:GetActTaskDailyRewardCfgByID(cfg.m_ID - 1)
  local iPreRequireScore = preCfg and preCfg.m_RequiredScore or 0
  local iRequireScore = cfg.m_RequiredScore
  local iCurHaveScore = iCurScore - iPreRequireScore
  local iCurNeedScore = iRequireScore - iPreRequireScore
  self.m_img_star_grey1:SetActive(false)
  self.m_img_star_grey2:SetActive(false)
  self.m_img_star_grey3:SetActive(false)
  for i = 1, iCurNeedScore do
    self["m_img_star_grey" .. i]:SetActive(true)
    self["m_img_star_light" .. i]:SetActive(i <= iCurHaveScore)
  end
  local bIsGot = iCurHaveScore >= iCurNeedScore
  local rewardList = utils.changeCSArrayToLuaTable(cfg.m_Reward)
  local scale
  utils.ShowPrefabHelper(self.prefabHelper, function(go, index, data)
    if not scale then
      scale = go.transform.localScale
    end
    go.transform.localScale = scale
    local rewardData = ResourceUtil:GetProcessRewardData({
      iID = data[1],
      iNum = data[2]
    })
    local commonItem = self:createCommonItem(go)
    commonItem:SetItemInfo(rewardData)
    commonItem:SetItemHaveGetActive(bIsGot)
    commonItem:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      self:OnRewardItemClick(itemID, itemNum, itemCom)
    end)
  end, rewardList)
end

function UIHeroAct103DailyTaskRewardItem:OnBtnreceiveClicked()
end

function UIHeroAct103DailyTaskRewardItem:dispose()
end

function UIHeroAct103DailyTaskRewardItem:OnRewardItemClick(itemId, itemNum, itemCom)
  utils.openItemDetailPop({iID = itemId, iNum = itemNum})
end

return UIHeroAct103DailyTaskRewardItem
