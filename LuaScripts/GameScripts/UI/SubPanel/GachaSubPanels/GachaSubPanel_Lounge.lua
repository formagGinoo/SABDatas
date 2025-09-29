local GachaSubPanelAct101 = require("UI/SubPanel/GachaSubPanels/GachaSubPanelAct101")
local GachaSubPanel_Lounge = class("GachaSubPanel_Lounge", GachaSubPanelAct101)
local Door_ShowTime = 5
local Door_AniOpen = "ui_Gacha110_Title_Door_open"
local Door_AniClose = "ui_Gacha110_Title_Door_close"

function GachaSubPanel_Lounge:OnFreshData()
  GachaSubPanel_Lounge.super.OnFreshData(self)
  self.m_stayTime = 0
  self.autoClose = true
  self.isShow = true
  UILuaHelper.PlayAnimationByName(self.m_pnl_door, Door_AniOpen)
end

function GachaSubPanel_Lounge:OnUpdate(dt)
  GachaSubPanel_Lounge.super.OnUpdate(self, dt)
  if self.autoClose then
    self.m_stayTime = self.m_stayTime + dt
    if self.m_stayTime >= Door_ShowTime then
      self.autoClose = false
      self.isShow = false
      UILuaHelper.PlayAnimationByName(self.m_pnl_door, Door_AniClose)
    end
  end
end

function GachaSubPanel_Lounge:OnArrowshowClicked()
  if self.autoClose then
    self.autoClose = false
  end
  self.isShow = not self.isShow
  UILuaHelper.PlayAnimationByName(self.m_pnl_door, self.isShow and Door_AniOpen or Door_AniClose)
end

function GachaSubPanel_Lounge:OnBtndoorClicked()
end

function GachaSubPanel_Lounge:OnHidePanel()
  GachaSubPanel_Lounge.super.OnHidePanel(self)
  self.autoClose = false
end

return GachaSubPanel_Lounge
