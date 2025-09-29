local Form_Inherit_Cost_Tips = class("Form_Inherit_Cost_Tips", require("UI/UIFrames/Form_Inherit_Cost_TipsUI"))

function Form_Inherit_Cost_Tips:SetInitParam(param)
end

function Form_Inherit_Cost_Tips:AfterInit()
  self.super.AfterInit(self)
  self.m_itemsInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_reward_InfinityGrid, "UICommonItem")
end

function Form_Inherit_Cost_Tips:OnActive()
  self.super.OnActive(self)
  self:FreshData()
end

function Form_Inherit_Cost_Tips:OnInactive()
  self.super.OnInactive(self)
end

function Form_Inherit_Cost_Tips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Inherit_Cost_Tips:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.heroIDList = tParam.heroIDList
    self.needItemConfig = tParam.needItemConfig
  end
  self.itemList = {}
  for _, v in pairs(self.needItemConfig) do
    log.info("_, v: " .. _, v)
    self.itemList[#self.itemList + 1] = ResourceUtil:GetProcessRewardData({
      iID = _,
      iNum = ItemManager:GetItemNum(_)
    })
    if v > ItemManager:GetItemNum(_) then
      local outputList = ItemManager:GetItemListByIdleCapsuleBase(_, v - ItemManager:GetItemNum(_))
      for _, _v in pairs(outputList) do
        log.info("_v: " .. _v.iID .. " " .. _v.iNum)
        self.itemList[#self.itemList + 1] = ResourceUtil:GetProcessRewardData({
          iID = _v.iID,
          iNum = _v.iNum
        })
      end
    end
  end
  print("self.itemList: " .. table.serialize(self.itemList))
  self.m_itemsInfinityGrid:ShowItemList(self.itemList)
end

function Form_Inherit_Cost_Tips:OnBtnYesClicked()
  InheritManager:ReqInheritBatchLevelUp(self.heroIDList)
  self:CloseForm()
end

function Form_Inherit_Cost_Tips:OnBtnNoClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_Inherit_Cost_Tips", Form_Inherit_Cost_Tips)
return Form_Inherit_Cost_Tips
