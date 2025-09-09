local Form_ActivityMinigame108Tip = class("Form_ActivityMinigame108Tip", require("UI/UIFrames/Form_ActivityMinigame108TipUI"))
local MiniGame108EquipIns = ConfigManager:GetConfigInsByName("MiniGame108Equipment")

function Form_ActivityMinigame108Tip:SetInitParam(param)
end

function Form_ActivityMinigame108Tip:AfterInit()
  self.super.AfterInit(self)
end

function Form_ActivityMinigame108Tip:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_iID = tParam.itemId
  self:FreshUI()
end

function Form_ActivityMinigame108Tip:FreshUI()
  if self.m_iID then
    local cfg = MiniGame108EquipIns:GetValue_ByEquipmentID(self.m_iID)
    if not cfg:GetError() then
      self.m_txt_icontitle_Text.text = cfg.m_mName
      self.m_txt_icondesc_Text.text = cfg.m_mDesc
      ResourceUtil:CreatIconById(self.m_item_Image, self.m_iID)
    end
  end
end

function Form_ActivityMinigame108Tip:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityMinigame108Tip:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityMinigame108Tip:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_ActivityMinigame108Tip:OnBtncloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMinigame108Tip", Form_ActivityMinigame108Tip)
return Form_ActivityMinigame108Tip
