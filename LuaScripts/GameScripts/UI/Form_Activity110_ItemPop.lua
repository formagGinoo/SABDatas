local Form_Activity110_ItemPop = class("Form_Activity110_ItemPop", require("UI/UIFrames/Form_Activity110_ItemPopUI"))
local levelTb = ConfigManager:GetConfigInsByName("MiniGameFlopLevelInfo")
local clueInfoTb = ConfigManager:GetConfigInsByName("MiniGameFlopClueInfo")

function Form_Activity110_ItemPop:SetInitParam(param)
end

function Form_Activity110_ItemPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity110_ItemPop:OnActive()
  self.super.OnActive(self)
  local Params = self.m_csui.m_param
  self.levelCfg = levelTb:GetValue_ByLevelID(Params.LevelId)
  local clueCfg = clueInfoTb:GetValue_ByClueID(self.levelCfg.m_Clue)
  self.m_txt_title2_Text.text = clueCfg.m_mName
  self.m_txt_desc2_Text.text = clueCfg.m_mDesc
  UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, clueCfg.m_Pic)
end

function Form_Activity110_ItemPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity110_ItemPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110_ItemPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_Activity110_ItemPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity110_ItemPop", Form_Activity110_ItemPop)
return Form_Activity110_ItemPop
