local Form_LoungeAdditionPop = class("Form_LoungeAdditionPop", require("UI/UIFrames/Form_LoungeAdditionPopUI"))
local InitPosTime = 0.06

function Form_LoungeAdditionPop:SetInitParam(param)
end

function Form_LoungeAdditionPop:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_DoubleTrigger = self.m_double_trigger:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnDoubleTriggerClk)
  end
  self.m_mulItemList = self:CreateCloneMulItemList(self.m_buff_list, self.m_baseBuff, "Lounge/UILoungeAdditionItem")
end

function Form_LoungeAdditionPop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_click_transform = tParam.click_transform
  self.m_pivot = tParam.content_pivot or {x = 0, y = 0}
  self.m_posOffset = tParam.pos_offset or {x = 0, y = 0}
  self.m_level = tParam.level or 0
  self.m_propertyIDList = tParam.propertyIDList or {}
  UILuaHelper.SetActive(self.m_content_node, false)
  self:RefreshUI()
  self:setTimer(InitPosTime, 1, function()
    if self.m_click_transform then
      self:InitSetPos()
    else
      UILuaHelper.SetLocalPosition(self.m_content_node, 0, 0, 0)
    end
  end)
  self.m_z_txt_nothing:SetActive(table.getn(self.m_propertyIDList) == 0)
end

function Form_LoungeAdditionPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoungeAdditionPop:RefreshUI()
  local attrList = LoungeManager:GetLoungeAttrByPropertyIDs(self.m_propertyIDList)
  self.m_mulItemList:ShowItemList(attrList)
  self.m_txt_title_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100120), self.m_level)
end

function Form_LoungeAdditionPop:InitSetPos()
  local pos = self.m_content_node.transform.parent:InverseTransformPoint(self.m_click_transform.position)
  UILuaHelper.SetLocalPosition(self.m_content_node, pos.x, pos.y, 0)
  local rectTransform = self.m_content_node:GetComponent("RectTransform")
  rectTransform.pivot = Vector2.New(self.m_pivot.x, self.m_pivot.y)
  UILuaHelper.SetLocalPosition(self.m_content_node, self.m_posOffset.x, self.m_posOffset.y, 0)
  UILuaHelper.SetActive(self.m_content_node, true)
end

function Form_LoungeAdditionPop:OnDoubleTriggerClk()
  self:CloseForm()
end

function Form_LoungeAdditionPop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_LoungeAdditionPop", Form_LoungeAdditionPop)
return Form_LoungeAdditionPop
