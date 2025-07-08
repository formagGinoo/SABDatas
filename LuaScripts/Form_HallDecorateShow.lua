local Form_HallDecorateShow = class("Form_HallDecorateShow", require("UI/UIFrames/Form_HallDecorateShowUI"))
local MainBgType = RoleManager.MainBgType

function Form_HallDecorateShow:SetInitParam(param)
end

function Form_HallDecorateShow:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk))
  self.m_curMainBgData = nil
  self.m_closeBackFun = nil
  self.m_bg_pic_trans = self.m_bg_pic.transform
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_curBgPrefabStr = nil
  self.m_curBgNodeObj = nil
end

function Form_HallDecorateShow:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_HallDecorateShow:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
  self:CheckRecycleBgNode()
end

function Form_HallDecorateShow:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
  self:CheckRecycleBgNode()
end

function Form_HallDecorateShow:FreshData()
  self.m_curMainBgData = nil
  self.m_closeBackFun = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curMainBgData = tParam.mainBgData
    self.m_closeBackFun = tParam.closeBackFun
    self.m_csui.m_param = nil
  end
end

function Form_HallDecorateShow:FreshUI()
  if not self.m_curMainBgData then
    return
  end
  local isRole = self.m_curMainBgData.iType == MainBgType.Role
  UILuaHelper.SetActive(self.m_root_role, isRole)
  if isRole then
    self:FreshShowSpine()
  end
  local isBg = self.m_curMainBgData.iType == MainBgType.Activity
  if isBg then
    self:FreshShowBg()
  else
    UILuaHelper.SetActiveChildren(self.m_bg_pic, false)
  end
end

function Form_HallDecorateShow:FreshShowSpine()
  local characterCfg = HeroManager:GetHeroConfigByID(self.m_curMainBgData.iId)
  if not characterCfg then
    return
  end
  self:ShowHeroSpine(characterCfg.m_Spine)
end

function Form_HallDecorateShow:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_HallDecorateShow:ShowHeroSpine(heroSpinePathStr)
  if not heroSpinePathStr then
    return
  end
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.MainShow
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_role, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack()
  end)
end

function Form_HallDecorateShow:OnLoadSpineBack()
  if not self.m_curHeroSpineObj then
    return
  end
  local spinePlaceObj = self.m_curHeroSpineObj.spinePlaceObj
  UILuaHelper.SetActive(spinePlaceObj, true)
  local spineRootObj = self.m_curHeroSpineObj.spineObj
  UILuaHelper.SpineResetMatParam(spineRootObj)
  UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
  UILuaHelper.SpinePlayAnimWithBack(spineRootObj, 0, "idle", true, false)
  if spineRootObj:GetComponent("SpineSkeletonPosControl") then
    spineRootObj:GetComponent("SpineSkeletonPosControl"):OnResetInit()
  end
end

function Form_HallDecorateShow:CheckRecycleBgNode()
  if self.m_curBgPrefabStr and self.m_curBgNodeObj then
    utils.RecycleInParentUIPrefab(self.m_curBgPrefabStr, self.m_curBgNodeObj)
  end
  self.m_curBgPrefabStr = nil
  self.m_curBgNodeObj = nil
end

function Form_HallDecorateShow:FreshShowBg()
  if not self.m_curMainBgData then
    return
  end
  local mainBackgroundCfg = RoleManager:GetMainBackgroundCfg(self.m_curMainBgData.iId)
  if not mainBackgroundCfg then
    return
  end
  self.m_curMainBackgroundCfg = mainBackgroundCfg
  local tempPrefabStr = mainBackgroundCfg.m_Prefabs
  if tempPrefabStr and tempPrefabStr ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_bg_pic_trans, tempPrefabStr, function(nameStr, gameObject)
      self.m_curBgPrefabStr = nameStr
      self.m_curBgNodeObj = gameObject
      self:FreshBgChild()
    end)
  end
end

function Form_HallDecorateShow:FreshBgChild()
  if not self.m_curMainBackgroundCfg then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_bg_pic_trans, false)
  local tempPrefabStr = self.m_curMainBackgroundCfg.m_Prefabs
  if tempPrefabStr and tempPrefabStr ~= "" then
    local subNode = self.m_bg_pic_trans:Find(tempPrefabStr)
    if subNode then
      UILuaHelper.SetActive(subNode, true)
    end
  end
end

function Form_HallDecorateShow:OnBackClk()
  if self.m_closeBackFun then
    self.m_closeBackFun()
  end
  GlobalManagerIns:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HallDecorateShow:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  if tParam.mainBgData then
    local mainBgData = tParam.mainBgData
    if mainBgData.iType == RoleManager.MainBgType.Activity then
      local mainBgCfg = RoleManager:GetMainBackgroundCfg(mainBgData.iId)
      if mainBgCfg then
        vResourceExtra[#vResourceExtra + 1] = {
          sName = mainBgCfg.m_Prefabs,
          eType = DownloadManager.ResourceType.UI
        }
      end
    elseif mainBgData.iType == RoleManager.MainBgType.Role then
      vPackage[#vPackage + 1] = {
        sName = tostring(mainBgData.iId),
        eType = DownloadManager.ResourcePackageType.Character
      }
    end
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_HallDecorateShow", Form_HallDecorateShow)
return Form_HallDecorateShow
