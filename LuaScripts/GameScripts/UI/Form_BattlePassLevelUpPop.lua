local Form_BattlePassLevelUpPop = class("Form_BattlePassLevelUpPop", require("UI/UIFrames/Form_BattlePassLevelUpPopUI"))
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus

function Form_BattlePassLevelUpPop:SetInitParam(param)
end

function Form_BattlePassLevelUpPop:AfterInit()
  self.super.AfterInit(self)
  self.m_stActivity = nil
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_widgetNumStepper = self:createNumStepper(self.m_rootTrans:Find("pnl_center/ui_common_stepper"))
  if self.m_oldColor == nil then
    self.m_oldColor = self.m_diamond_num_Text.color
  end
  local resourceBarRoot = self.m_rootTrans:Find("pnl_center/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self:InitRewardItem()
end

function Form_BattlePassLevelUpPop:OnActive()
  self.super.OnActive(self)
  self:InitView()
end

function Form_BattlePassLevelUpPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_BattlePassLevelUpPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BattlePassLevelUpPop:InitRewardItem()
  self.m_itemDataList = {}
  self.m_rewardItemBase = self.m_item_high.transform
  self.m_itemNodeList = {}
  local itemNode = self:CreateItemNode(self.m_rewardItemBase)
  self.m_itemNameStr = self.m_rewardItemBase.name
  self.m_itemNodeList[#self.m_itemNodeList + 1] = itemNode
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
end

function Form_BattlePassLevelUpPop:InitView()
  local tParam = self.m_csui.m_param
  self.m_stActivity = tParam.stActivity
  self.m_upLevelExpNum = self.m_stActivity:GetUpLevelExp()
  self.m_perExpCostDiamondNum = self.m_stActivity:GetCostPerExp()
  self.m_maxLevel = self.m_stActivity:GetMaxLevel()
  self.m_curLevel = self.m_stActivity:GetCurLevel()
  self.m_curExp = self.m_stActivity:GetCurExp()
  self.m_widgetResourceBar:FreshChangeItems({
    [1] = MTTDProto.SpecialItem_ShowDiamond
  })
  self.m_widgetNumStepper:SetNumShowMax(true)
  self.m_widgetNumStepper:SetNumMin(1)
  self.m_widgetNumStepper:SetNumMax(self.m_maxLevel - self.m_curLevel)
  self.m_widgetNumStepper:SetNumCur(1)
  self.m_widgetNumStepper:SetNumChangeCB(handler(self, self.OnNumChangeCB), nil)
  local rect = self.m_diamond_num:GetComponent(T_RectTransform)
  rect.sizeDelta = Vector2.New(100, rect.sizeDelta.y)
  self.m_txt_bp_before_num_Text.text = self.m_curLevel
  self:SetTargetLevel(self.m_curLevel + 1)
end

function Form_BattlePassLevelUpPop:SetTargetLevel(toLevel)
  self.m_toLevel = toLevel
  self.m_txt_bp_after_num_Text.text = toLevel
  self.m_z_txt_lv_max:SetActive(toLevel == self.m_maxLevel)
  self.m_toLevelNeedExp = self.m_upLevelExpNum - self.m_curExp + (toLevel - self.m_curLevel - 1) * self.m_upLevelExpNum
  self.m_txt_buylevel_Text.text = self.m_toLevelNeedExp
  self.m_needDiamond = self.m_toLevelNeedExp * self.m_perExpCostDiamondNum
  self.m_diamond_num_Text.text = self.m_needDiamond
  if ItemManager:GetItemNum(MTTDProto.SpecialItem_ShowDiamond) < self.m_needDiamond then
    self.m_diamond_num_Text.color = Color.red
  else
    self.m_diamond_num_Text.color = self.m_oldColor
  end
  self:FreshLevelInfoShow()
  self:FreshItemRewardData()
  self:FreshRewardItems()
end

function Form_BattlePassLevelUpPop:FreshLevelInfoShow()
  if not self.m_toLevel then
    return
  end
  self.m_txt_rank_Text.text = self.m_toLevel
  self.m_txt_tasklevelnum_Text.text = "0/" .. self.m_upLevelExpNum
  self.m_slider_level_Image.fillAmount = 0
end

function Form_BattlePassLevelUpPop:FreshItemRewardData()
  if not self.m_stActivity then
    return
  end
  if not self.m_toLevel then
    return
  end
  local buyStatus = self.m_stActivity:GetBuyStatus()
  self.m_itemDataList = {}
  local tempItemDic = {}
  for i = self.m_curLevel + 1, self.m_toLevel do
    local tempLvNum = i
    local levelCfg = self.m_stActivity:GetLevelCfg(tempLvNum)
    if levelCfg then
      local freeRewardList = levelCfg.vFreeReward
      for _, tempCmdIDNum in ipairs(freeRewardList) do
        local itemID = tempCmdIDNum.iID
        local itemNum = tempCmdIDNum.iNum
        if tempItemDic[itemID] == nil then
          tempItemDic[itemID] = {iID = itemID, iNum = itemNum}
        else
          tempItemDic[itemID].iNum = tempItemDic[itemID].iNum + itemNum
        end
      end
      if buyStatus == BattlePassBuyStatus.Paid or buyStatus == BattlePassBuyStatus.Advanced then
        local paidRewardList = levelCfg.vPaidReward
        for _, tempCmdIDNum in ipairs(paidRewardList) do
          local itemID = tempCmdIDNum.iID
          local itemNum = tempCmdIDNum.iNum
          if tempItemDic[itemID] == nil then
            tempItemDic[itemID] = {iID = itemID, iNum = itemNum}
          else
            tempItemDic[itemID].iNum = tempItemDic[itemID].iNum + itemNum
          end
        end
      end
    end
  end
  for i, v in pairs(tempItemDic) do
    local itemData = ResourceUtil:GetProcessRewardData(v)
    v.itemData = itemData
    self.m_itemDataList[#self.m_itemDataList + 1] = v
  end
  table.sort(self.m_itemDataList, function(a, b)
    if a.itemData.quality ~= b.itemData.quality then
      return a.itemData.quality > b.itemData.quality
    end
    return a.iID < b.iID
  end)
end

function Form_BattlePassLevelUpPop:CreateItemNode(itemObj)
  if not itemObj then
    return
  end
  local widget = self:createCommonItem(itemObj)
  widget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
    self:OnRewardItemClick(itemID, itemNum, itemCom)
  end)
  return widget
end

function Form_BattlePassLevelUpPop:FreshItemNodeShow(itemNode, itemData)
  local itemWidget = itemNode
  itemWidget:SetItemInfo(itemData.itemData)
end

function Form_BattlePassLevelUpPop:FreshRewardItems()
  if not self.m_itemDataList then
    return
  end
  local dataLen = #self.m_itemDataList
  if dataLen == 0 then
    UILuaHelper.SetActive(self.m_list_itemhigh, false)
    UILuaHelper.SetActive(self.m_pnl_empty, true)
  else
    UILuaHelper.SetActive(self.m_list_itemhigh, true)
    UILuaHelper.SetActive(self.m_pnl_empty, false)
    local itemNodes = self.m_itemNodeList
    local parentTrans = self.m_list_itemhigh.transform
    local childCount = #itemNodes
    local totalFreshNum = dataLen < childCount and childCount or dataLen
    for i = 1, totalFreshNum do
      if i <= childCount and i <= dataLen then
        local itemNode = itemNodes[i]
        self:FreshItemNodeShow(itemNode, self.m_itemDataList[i])
        itemNode:SetActive(true)
      elseif i > childCount and i <= dataLen then
        local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans).gameObject
        itemObj.name = self.m_itemNameStr .. i
        local itemNode = self:CreateItemNode(itemObj)
        itemNodes[#itemNodes + 1] = itemNode
        local itemData = self.m_itemDataList[i]
        self:FreshItemNodeShow(itemNode, itemData)
        itemNode:SetActive(true)
      elseif i <= childCount and i > dataLen then
        itemNodes[i]:SetActive(false)
      end
    end
  end
end

function Form_BattlePassLevelUpPop:OnBtnconfirmClicked()
  if ItemManager:GetItemNum(MTTDProto.SpecialItem_ShowDiamond) < self.m_needDiamond then
    utils.CheckAndPushCommonTips({
      tipsID = 1750,
      func1 = function()
        QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
      end
    })
    return
  end
  self.m_stActivity:RequestBuyExp(self.m_toLevelNeedExp, function()
    StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, 20100)
    self:CloseForm()
  end)
end

function Form_BattlePassLevelUpPop:OnNumChangeCB()
  self:SetTargetLevel(self.m_curLevel + self.m_widgetNumStepper:GetNumCur())
end

function Form_BattlePassLevelUpPop:OnRewardItemClick(iItemId, iItemNum)
  utils.openItemDetailPop({iID = iItemId, iNum = iItemNum})
end

function Form_BattlePassLevelUpPop:IsFullScreen()
  return false
end

function Form_BattlePassLevelUpPop:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_BattlePassLevelUpPop", Form_BattlePassLevelUpPop)
return Form_BattlePassLevelUpPop
