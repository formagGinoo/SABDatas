local Form_PopupLevelReset = class("Form_PopupLevelReset", require("UI/UIFrames/Form_PopupLevelResetUI"))

function Form_PopupLevelReset:SetInitParam(param)
end

function Form_PopupLevelReset:AfterInit()
  self.super.AfterInit(self)
  local parentTran = self.m_btn_consume.transform.parent.transform
  self.m_consumeIconImg = parentTran:Find("img_jb_bg/consume_quantity/consume_icon"):GetComponent("Image")
  self.m_consumeNumTxt = parentTran:Find("img_jb_bg/consume_quantity"):GetComponent(T_TextMeshProUGUI)
  self.m_consumeContentTxt = self.m_btn_consume.transform:Find("txt_content"):GetComponent(T_TextMeshProUGUI)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
  self:createResourceBar(self.m_top_resource)
end

function Form_PopupLevelReset:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_curShowHeroData = tParam.heroData
  local serverData = self.m_curShowHeroData.serverData
  self.m_iLevel = serverData.iLevel
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_PopupLevelReset:OnInactive()
  self:RemoveAllEventListeners()
end

function Form_PopupLevelReset:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_PopupLevelReset:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PopupLevelReset:RefreshUI()
  self.m_rewardList = {}
  self.m_txt_lv_before_Text.text = string.format(ConfigManager:GetCommonTextById(20033), tostring(self.m_iLevel))
  self.m_txt_lv_after_Text.text = string.format(ConfigManager:GetCommonTextById(20033), 1)
  self.m_consumeContentTxt.text = ConfigManager:GetCommonTextById(20032)
  self:CalculateConsumeMaterials()
  local itemId, needItemNum
  local costStr = ConfigManager:GetGlobalSettingsByKey("ResetLevelCost")
  local costTab = utils.changeStringRewardToLuaTable(costStr)
  if costTab and costTab[1] then
    itemId = costTab[1][1]
    needItemNum = costTab[1][2]
  else
    log.error("GlobalSettings  ResetLevelCost  can not find")
    return
  end
  self.m_needItemId = itemId
  self.m_needItemNum = needItemNum
  ResourceUtil:CreateItemIcon(self.m_consumeIconImg, itemId)
  self.m_consumeNumTxt.text = needItemNum
  local userItemNum = ItemManager:GetItemNum(itemId, true)
  if needItemNum > userItemNum then
    self.m_canResetLv = false
    UILuaHelper.SetColor(self.m_consumeNumTxt, 255, 0, 0, 255)
  else
    self.m_canResetLv = true
    UILuaHelper.SetColor(self.m_consumeNumTxt, 84, 78, 71, 255)
  end
end

function Form_PopupLevelReset:CalculateConsumeMaterials()
  local characterLevelIns = ConfigManager:GetConfigInsByName("CharacterLevel")
  local expItem = {iID = 1001, iNum = 0}
  local goldItem = {iID = 999, iNum = 0}
  local throughItem = {iID = 1002, iNum = 0}
  for i = 1, self.m_iLevel - 1 do
    local characterLevelCfg = characterLevelIns:GetValue_ByCharacterLv(i)
    if not characterLevelCfg:GetError() then
      expItem.iNum = expItem.iNum + characterLevelCfg.m_LvExp
      goldItem.iNum = goldItem.iNum + characterLevelCfg.m_LvMoney
      throughItem.iNum = throughItem.iNum + characterLevelCfg.m_LvBreakthrough
    end
  end
  self.m_rewardList = {
    expItem,
    goldItem,
    throughItem
  }
  for i = #self.m_rewardList, 1, -1 do
    if self.m_rewardList[i].iNum == 0 then
      self.m_rewardList[i] = nil
    end
  end
  self:RefreshRewardList()
end

function Form_PopupLevelReset:RefreshRewardList()
  local dataList = {}
  for i, v in ipairs(self.m_rewardList) do
    local processData = ResourceUtil:GetProcessRewardData(v)
    dataList[#dataList + 1] = processData
  end
  self.m_rewardListInfinityGrid:ShowItemList(dataList)
end

function Form_PopupLevelReset:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_rewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.iID,
      iNum = chooseFJItemData.iNum
    })
  end
end

function Form_PopupLevelReset:OnBtnconsumeClicked()
  if self.m_needItemId then
    local itemCfg = ItemManager:GetItemConfigById(self.m_needItemId)
    if not self.m_canResetLv then
      utils.CheckAndPushCommonTips({
        tipsID = 1222,
        func1 = function()
          QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
          StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_POPUPLEVELRESET)
        end
      })
      return
    end
    utils.CheckAndPushCommonTips({
      tipsID = 1211,
      fContentCB = function(sContent)
        return string.format(sContent, tostring(itemCfg.m_mItemName), tostring(self.m_needItemNum))
      end,
      func1 = function()
        HeroManager:ReqHeroResetLevel(self.m_curShowHeroData.serverData.iHeroId)
        StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_POPUPLEVELRESET)
      end
    })
  end
end

function Form_PopupLevelReset:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_POPUPLEVELRESET)
end

function Form_PopupLevelReset:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_POPUPLEVELRESET)
end

function Form_PopupLevelReset:IsOpenGuassianBlur()
  return true
end

function Form_PopupLevelReset:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_PopupLevelReset", Form_PopupLevelReset)
return Form_PopupLevelReset
