local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroEquipSubPanel = class("HeroEquipSubPanel", UISubPanelBase)
local __EQUIP_PART_NUM = 4
local EnterAnimStr = "equipment_in"
local TabInAnimStr = "equipment_in"

function HeroEquipSubPanel:OnInit()
  self.m_curShowHeroData = nil
  for i = 1, __EQUIP_PART_NUM do
    self["m_pnl_equip0" .. i]:SetActive(false)
  end
  self.m_pnl_right_down:SetActive(true)
  self.m_selEquipData = nil
  self.m_selPos = nil
  self.m_equipDataList = {}
  self.m_equipPosDataList = {}
  self.m_hPanelEquip = {}
  self:AddEventListeners()
  self.m_openTime = 0
  self.m_quickEquippedList = {}
end

function HeroEquipSubPanel:OnFreshData()
  self.m_pnl_right_down:SetActive(true)
  self.m_curShowHeroData = self.m_panelData.heroData
  self:RefreshUI()
end

function HeroEquipSubPanel:RefreshUI()
  local serverData = self.m_curShowHeroData.serverData
  local heroCfg = self.m_curShowHeroData.characterCfg
  self.m_equipDataList = serverData.mEquip
  self.m_equipPosDataList = {}
  self.m_equipType = heroCfg.m_Equiptype
  local equipList = EquipManager:GetBestEquipsForHero(serverData.iHeroId)
  for i = 1, __EQUIP_PART_NUM do
    self["m_ui_hero_panel_equipment_fx" .. i]:SetActive(false)
    self["m_t10_confirm0" .. i]:SetActive(false)
    if self.m_equipDataList[i] then
      self["m_pnl_equip0" .. i]:SetActive(true)
      self["m_icon_redpoint0" .. i]:SetActive(false)
      if self.m_quickEquippedList[i] then
        self["m_ui_hero_panel_equipment_fx" .. i]:SetActive(true)
      end
      if self.m_hPanelEquip[i] == nil then
        self.m_hPanelEquip[i] = self:createCommonItem(self["m_pnl_equip0" .. i].gameObject)
      end
      local processData = ResourceUtil:GetProcessRewardData({
        iID = self.m_equipDataList[i].iBaseId,
        iNum = 1
      }, self.m_equipDataList[i])
      self.m_hPanelEquip[i]:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnEquippedItemClk(itemID, itemNum, itemCom)
      end)
      if processData then
        self.m_hPanelEquip[i]:SetItemInfo(processData)
        self.m_hPanelEquip[i]:ShowHeroIcon(false)
      end
      if self.m_equipDataList[i].iOverloadHero and self.m_equipDataList[i].mChangingEffect and table.getn(self.m_equipDataList[i].mChangingEffect) > 0 then
        self["m_t10_confirm0" .. i]:SetActive(true)
      end
    else
      self["m_pnl_equip0" .. i]:SetActive(false)
    end
    self["m_icon_redpoint0" .. i]:SetActive(equipList[i] ~= nil)
  end
  self.m_quickEquippedList = {}
end

function HeroEquipSubPanel:OnActivePanel()
  self.m_openTime = TimeUtil:GetServerTimeS()
  ReportManager:ReportSystemOpen(GlobalConfig.SYSTEM_ID.Equip, self.m_openTime)
end

function HeroEquipSubPanel:OnHidePanel()
  ReportManager:ReportSystemClose(GlobalConfig.SYSTEM_ID.Equip, self.m_openTime)
end

function HeroEquipSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Equip_InstallEquip", handler(self, self.OnEventInstallEquip))
  self:addEventListener("eGameEvent_Equip_UnInstallEquip", handler(self, self.OnEventUnInstallEquip))
  self:addEventListener("eGameEvent_Equip_ChangeEquip", handler(self, self.OnEventChangeEquip))
  self:addEventListener("eGameEvent_Equip_AddExp", handler(self, self.OnEventAddExp))
end

function HeroEquipSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function HeroEquipSubPanel:OnEventAddExp()
  self:OnFreshData()
end

function HeroEquipSubPanel:OnEventInstallEquip(data)
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30001)
  if data and type(data) == "number" then
    self.m_quickEquippedList = {}
    self.m_quickEquippedList[data] = true
  elseif data and type(data) == "table" then
    self.m_quickEquippedList = data
  end
  self.m_selPos = nil
  self:OnFreshData()
end

function HeroEquipSubPanel:OnEventUnInstallEquip()
  self:OnFreshData()
end

function HeroEquipSubPanel:OnEventChangeEquip(pos)
  StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPREPLACEPOP, {
    heroData = self.m_curShowHeroData,
    pos = pos
  })
end

function HeroEquipSubPanel:ShowEnterInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, EnterAnimStr)
end

function HeroEquipSubPanel:ShowTabInAnim()
  if not self.m_rootObj then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_rootObj, TabInAnimStr)
end

function HeroEquipSubPanel:OnEquippedItemClk(itemID, itemNum, itemCom)
  if self.m_equipDataList then
    for pos, v in pairs(self.m_equipDataList) do
      if v.iBaseId == itemID then
        self.m_selPos = pos
        if self.m_equipDataList[pos].iOverloadHero and self.m_equipDataList[pos].iOverloadHero ~= 0 then
          if 0 < table.getn(self.m_equipDataList[pos].mChangingEffect) then
            utils.popUpDirectionsUI({
              tipsID = 1703,
              func1 = function()
                StackPopup:Push(UIDefines.ID_FORM_EQUIPT10OVERLOADRANDOMWORD, {
                  equipData = self.m_equipDataList[pos]
                })
              end,
              func2 = function()
                StackPopup:Push(UIDefines.ID_FORM_EQUIPT10OVERLOADRANDOMWORD, {
                  equipData = self.m_equipDataList[pos]
                })
              end
            })
            break
          end
          StackPopup:Push(UIDefines.ID_FORM_ITEMTIPST10, {
            equipData = self.m_equipDataList[pos],
            pos = pos
          })
          break
        end
        StackPopup:Push(UIDefines.ID_FORM_ITEMTIPS, {
          equipData = self.m_equipDataList[pos],
          pos = pos
        })
        break
      end
    end
  end
end

function HeroEquipSubPanel:OnPart01Clicked()
  local pos = 1
  self.m_selPos = pos
  self:OpenEquipReplacePop(self.m_selPos)
end

function HeroEquipSubPanel:OnPart02Clicked()
  local pos = 2
  self.m_selPos = pos
  self:OpenEquipReplacePop(self.m_selPos)
end

function HeroEquipSubPanel:OnPart03Clicked()
  local pos = 3
  self.m_selPos = pos
  self:OpenEquipReplacePop(self.m_selPos)
end

function HeroEquipSubPanel:OnPart04Clicked()
  local pos = 4
  self.m_selPos = pos
  self:OpenEquipReplacePop(self.m_selPos)
end

function HeroEquipSubPanel:OpenEquipReplacePop(pos)
  StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPREPLACEPOP, {
    heroData = self.m_curShowHeroData,
    pos = pos
  })
end

function HeroEquipSubPanel:OnBtntakeoffClicked()
  local canTakeOff = false
  for i, v in pairs(self.m_equipDataList) do
    if v.iOverloadHero == 0 then
      canTakeOff = true
    end
  end
  if not canTakeOff then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20039)
    return
  end
  if table.getn(self.m_equipDataList) == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30003)
    return
  end
  EquipManager:ReqUnInstallAllEquip(self.m_curShowHeroData.serverData.iHeroId)
end

function HeroEquipSubPanel:OnBtnquickClicked()
  local equipIdList = EquipManager:GetBestEquipsForHero(self.m_curShowHeroData.serverData.iHeroId)
  self.m_quickEquippedList = equipIdList
  if table.getn(equipIdList) > 0 then
    EquipManager:ReqInstallEquipBatch(self.m_curShowHeroData.serverData.iHeroId, equipIdList)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20040)
  end
end

return HeroEquipSubPanel
