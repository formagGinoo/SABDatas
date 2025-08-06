local BaseModule = require("Module/BaseModule")
local BossModule = class("BossModule", BaseModule)
BossModule.BossAnimType = {Show = 1, Idle = 2}
BossModule.BossAnimTable = {
  [BossModule.BossAnimType.Show] = {
    camera = "Dungeon_Camera_Show",
    boss = "dungeon_show",
    light = "Dungeon_Light_Show"
  },
  [BossModule.BossAnimType.Idle] = {
    camera = "Dungeon_Camera_Idle",
    boss = "dungeon_idle",
    light = "Dungeon_Light_Idle"
  }
}

function BossModule:ctor(...)
  BossModule.super.ctor(self, ...)
  self.m_monoGameObjectTrans = nil
  self.m_bossObjTab = {}
  self.m_bossCameraTab = {}
  self.m_bossPosObjTab = {}
  self.m_bossAnimatorTab = {}
  self.m_bossLightObjTab = {}
end

function BossModule:onReset()
end

function BossModule:onSetVisible(isVisible)
end

function BossModule:onDestroyUI(uid, uiStack)
end

function BossModule:onPushUI(uid, uiStack)
end

function BossModule:onAfterInitUI(uid, uiStack)
end

function BossModule:onActiveUI(uid, uiStack)
end

function BossModule:onInActiveUI(uid, uiStack)
end

function BossModule:onDestroyUI(uid, uiStack)
end

function BossModule:GetMonoGameObjectTrans()
  if not self.m_monoGameObjectTrans then
    local tempObj = GameObject.Find("MONOGameObject")
    if tempObj and not UILuaHelper.IsNull(tempObj) then
      self.m_monoGameObjectTrans = tempObj.transform
    end
  end
  return self.m_monoGameObjectTrans
end

function BossModule:CreateBossPosNode(allLoadBackFun)
  local monoTrans = self:GetMonoGameObjectTrans()
  if not monoTrans or UILuaHelper.IsNull(monoTrans) then
    return
  end
  local equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not equipmentHelper then
    return
  end
  local posResList = equipmentHelper:GetTodayBossResName()
  if not posResList then
    return
  end
  local maxResListNum = #posResList
  local curLoadBackNum = 0
  
  local function checkAllLoadEnd()
    curLoadBackNum = curLoadBackNum + 1
    if curLoadBackNum >= maxResListNum and allLoadBackFun then
      allLoadBackFun()
    end
  end
  
  self.m_bossPosResNameList = {}
  for order, posRes in pairs(posResList) do
    if posRes and posRes ~= "" then
      self.m_bossPosResNameList[#self.m_bossPosResNameList + 1] = posRes
      local pObj = monoTrans:Find(posRes)
      if utils.isNull(pObj) then
        ResourceUtil:LoadPrefabAsync(posRes, function(object)
          local itemRoot = GameObject.Instantiate(object, monoTrans)
          itemRoot.name = posRes
          UILuaHelper.SetActive(itemRoot, false)
          if not utils.isNull(self.m_bossPosObjTab[posRes]) and table.indexof(self.m_bossPosResNameList, posRes) and allLoadBackFun then
            local itemObj = self.m_bossPosObjTab[posRes]
            GameObject.Destroy(itemObj)
            self.m_bossPosObjTab[posRes] = itemRoot
            UILuaHelper.SetParent(itemRoot, monoTrans, true)
            UILuaHelper.SetLocalPosition(itemRoot, 10000, 10000, 0)
            log.error("bossPosObj is repeat !!!")
          elseif not utils.isNull(self.m_bossPosObjTab[posRes]) and table.indexof(self.m_bossPosResNameList, posRes) and not allLoadBackFun then
            GameObject.Destroy(itemRoot)
          else
            self.m_bossPosObjTab[posRes] = itemRoot
            UILuaHelper.SetParent(itemRoot, monoTrans, true)
            UILuaHelper.SetLocalPosition(itemRoot, 10000, 10000, 0)
          end
          checkAllLoadEnd()
        end)
      else
        self.m_bossPosObjTab[posRes] = pObj
        checkAllLoadEnd()
      end
    end
  end
end

function BossModule:CreateBossPosNodeBySortId(sortId, allLoadBackFun)
  local monoTrans = self:GetMonoGameObjectTrans()
  if not monoTrans or UILuaHelper.IsNull(monoTrans) then
    return
  end
  local equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not equipmentHelper then
    return
  end
  local chapterInfo = equipmentHelper:GetDunChapterByOrderId(sortId)
  if not chapterInfo then
    return
  end
  local posRes = chapterInfo.m_Point
  local maxResListNum = 1
  local curLoadBackNum = 0
  
  local function checkAllLoadEnd()
    curLoadBackNum = curLoadBackNum + 1
    if curLoadBackNum >= maxResListNum and allLoadBackFun then
      allLoadBackFun()
    end
  end
  
  if not self.m_bossPosResNameList then
    self.m_bossPosResNameList = {}
  end
  local isHave = table.indexof(self.m_bossPosResNameList, posRes)
  if not isHave and posRes and posRes ~= "" then
    self.m_bossPosResNameList[#self.m_bossPosResNameList + 1] = posRes
    local pObj = monoTrans:Find(posRes)
    if utils.isNull(pObj) then
      ResourceUtil:LoadPrefabAsync(posRes, function(object)
        local itemRoot = GameObject.Instantiate(object, monoTrans)
        itemRoot.name = posRes
        UILuaHelper.SetActive(itemRoot, false)
        if not utils.isNull(self.m_bossPosObjTab[posRes]) and table.indexof(self.m_bossPosResNameList, posRes) and allLoadBackFun then
          local itemObj = self.m_bossPosObjTab[posRes]
          GameObject.Destroy(itemObj)
          self.m_bossPosObjTab[posRes] = itemRoot
          UILuaHelper.SetParent(itemRoot, monoTrans, true)
          UILuaHelper.SetLocalPosition(itemRoot, 10000, 10000, 0)
          log.error("bossPosObj is repeat !!!")
        elseif not utils.isNull(self.m_bossPosObjTab[posRes]) and table.indexof(self.m_bossPosResNameList, posRes) and not allLoadBackFun then
          GameObject.Destroy(itemRoot)
        else
          self.m_bossPosObjTab[posRes] = itemRoot
          UILuaHelper.SetParent(itemRoot, monoTrans, true)
          UILuaHelper.SetLocalPosition(itemRoot, 10000, 10000, 0)
        end
        checkAllLoadEnd()
      end)
    else
      self.m_bossPosObjTab[posRes] = pObj
      checkAllLoadEnd()
    end
  elseif not self.m_bossPosObjTab[posRes] then
    local pObj = monoTrans:Find(posRes)
    if not utils.isNull(pObj) then
      self.m_bossPosObjTab[posRes] = pObj
      checkAllLoadEnd()
    end
  else
    checkAllLoadEnd()
  end
end

function BossModule:ClearAllBossRes()
  self.m_bossCameraTab = {}
  self.m_bossLightObjTab = {}
  self:ClearBossRes()
  self:ClearBossPosNode()
end

function BossModule:ClearBossPosNode()
  if self.m_bossPosObjTab then
    for name, posObj in pairs(self.m_bossPosObjTab) do
      if not utils.isNull(posObj) then
        GameObject.Destroy(posObj.gameObject)
        ResourceUtil:UnLoadPrefabAsync(name)
      end
    end
    self.m_bossPosObjTab = {}
  end
  self.m_bossPosResNameList = {}
end

function BossModule:ForceRemoveBossPosNode()
  local monoTrans = self:GetMonoGameObjectTrans()
  if not monoTrans or UILuaHelper.IsNull(monoTrans) then
    return
  end
  local equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not equipmentHelper then
    return
  end
  local posResList = equipmentHelper:GetTodayBossResName()
  if table.getn(posResList) > 0 then
    for order, posRes in pairs(posResList) do
      if posRes and posRes ~= "" then
        local posTrans = monoTrans:Find(posRes)
        if not utils.isNull(posTrans) and posTrans ~= monoTrans then
          GameObject.Destroy(posTrans.gameObject)
          ResourceUtil:UnLoadPrefabAsync(posRes)
          log.error("ClearBossPosNode bossPosObj is repeat !!!")
        end
      end
    end
  end
end

function BossModule:ClearBossRes()
  if self.m_bossObjTab then
    for name, posObj in pairs(self.m_bossObjTab) do
      if not utils.isNull(posObj) then
        Role3DManager:DestroyRoleObj(posObj.gameObject, name, self.m_bossAnimatorTab[name])
      end
    end
    self.m_bossObjTab = {}
  end
end

function BossModule:CreateBoss3DResBySortId(sortId)
  if not sortId then
    return
  end
  local equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not equipmentHelper then
    return
  end
  local chapterInfo = equipmentHelper:GetDunChapterByOrderId(sortId)
  if not chapterInfo then
    return
  end
  local posNodeObj = self.m_bossPosObjTab[chapterInfo.m_Point]
  if posNodeObj then
    if not self.m_bossObjTab[chapterInfo.m_Model] then
      local function callback(name, result)
        self.m_bossObjTab[name] = result
        
        self.m_bossAnimatorTab[name] = chapterInfo.m_Animator
        local posNodeTran = posNodeObj.transform
        local posObj = posNodeTran:Find("Boss_Position")
        if not utils.isNull(posObj) then
          UILuaHelper.SetActive(result, true)
          UILuaHelper.SetParent(result, posObj.transform, true)
          local cameraObj = posNodeTran:Find("Camera")
          if not utils.isNull(cameraObj) then
            local camera = cameraObj:GetComponent(T_Camera)
            self.m_bossCameraTab[name] = camera
          end
          local sceneNode = posNodeTran:Find("Scene")
          if not utils.isNull(sceneNode) then
            local firstChild = sceneNode:GetChild(0)
            if not utils.isNull(firstChild) then
              local lightNode = firstChild:Find("Detail/Light")
              if not utils.isNull(lightNode) then
                self.m_bossLightObjTab[name] = lightNode.gameObject
              end
            end
          end
        end
      end
      
      Role3DManager:LoadRoleAsync(chapterInfo.m_Model, chapterInfo.m_Animator, callback)
    end
  else
    local function callBack()
      self:CreateBoss3DResBySortId(sortId)
    end
    
    if CS.GameQualityManager.DestroyBossChapterInBattle then
      self:CreateBossPosNodeBySortId(sortId, callBack)
    else
      self:CreateBossPosNode(callBack)
    end
  end
end

function BossModule:HideAllBossPosAndResetMainCamera(curLevelSubType)
  if not curLevelSubType then
    return
  end
  if not self.m_bossPosObjTab then
    return
  end
  local levelEquipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not levelEquipmentHelper then
    return
  end
  local chapterInfo = levelEquipmentHelper:GetDunChapterById(curLevelSubType)
  if not chapterInfo then
    return
  end
  if not utils.isNull(self.m_bossCameraTab[chapterInfo.m_Model]) then
    UILuaHelper.SetMainCamera(false, self.m_bossCameraTab[chapterInfo.m_Model])
  end
  for _, v in pairs(self.m_bossPosObjTab) do
    if v and not UILuaHelper.IsNull(v) then
      UILuaHelper.SetActive(v, false)
    end
  end
end

function BossModule:ChangeBossMainCameraByName(sortId)
  local levelEquipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not levelEquipmentHelper then
    return
  end
  local chapterInfo = levelEquipmentHelper:GetDunChapterByOrderId(sortId)
  if not chapterInfo then
    return
  end
  if not utils.isNull(self.m_bossCameraTab[chapterInfo.m_Model]) then
    self:ShowBossPosNode(sortId)
    UILuaHelper.SetMainCamera(true, self.m_bossCameraTab[chapterInfo.m_Model])
    return true
  else
    return false
  end
end

function BossModule:ShowBossPosNode(sortId)
  if not sortId then
    return
  end
  if not self.m_bossPosObjTab then
    return
  end
  local levelEquipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not levelEquipmentHelper then
    return
  end
  local chapterInfo = levelEquipmentHelper:GetDunChapterByOrderId(sortId)
  if not chapterInfo then
    return
  end
  local m_Point = chapterInfo.m_Point
  for name, v in pairs(self.m_bossPosObjTab) do
    if m_Point == name then
      UILuaHelper.SetActive(v, true)
      if not UILuaHelper.IsNull(v) then
        UILuaHelper.SetLocalPosition(v, 0, 0, 0)
      end
    else
      UILuaHelper.SetActive(v, false)
      if not UILuaHelper.IsNull(v) then
        UILuaHelper.SetLocalPosition(v, 10000, 10000, 0)
      end
    end
  end
end

function BossModule:GetBossModelNameBySortID(sortID)
  if not sortID then
    return
  end
  local levelEquipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not levelEquipmentHelper then
    return
  end
  local chapterInfo = levelEquipmentHelper:GetDunChapterByOrderId(sortID)
  if not chapterInfo then
    return
  end
  local moduleStr = chapterInfo.m_Model
  if moduleStr == nil or moduleStr == "" then
    return
  end
  return moduleStr
end

function BossModule:GetBossObjByModelStr(modelStr)
  if not modelStr then
    return
  end
  if not self.m_bossObjTab then
    return
  end
  return self.m_bossObjTab[modelStr]
end

function BossModule:GetBossCameraByModelStr(modelStr)
  if not modelStr then
    return
  end
  if not self.m_bossCameraTab then
    return
  end
  return self.m_bossCameraTab[modelStr]
end

function BossModule:GetBossLightObjByModelStr(modelStr)
  if not modelStr then
    return
  end
  if not self.m_bossLightObjTab then
    return
  end
  return self.m_bossLightObjTab[modelStr]
end

function BossModule:GetBossObjBySortID(sortId)
  if not sortId then
    return
  end
  if not self.m_bossPosObjTab then
    return
  end
  local levelEquipmentHelper = LevelManager:GetLevelEquipmentHelper()
  if not levelEquipmentHelper then
    return
  end
  local chapterInfo = levelEquipmentHelper:GetDunChapterByOrderId(sortId)
  if not chapterInfo then
    return
  end
  local moduleStr = chapterInfo.m_Model
  if moduleStr == nil or moduleStr == "" then
    return
  end
  return self.m_bossObjTab[moduleStr]
end

function BossModule:PlayAnimatorBySortIDAndType(sortID, bossAnimType)
  if not sortID then
    return
  end
  if not bossAnimType then
    return
  end
  local animTab = self.BossAnimTable[bossAnimType]
  if not animTab then
    return
  end
  local modelStr = self:GetBossModelNameBySortID(sortID)
  if not modelStr then
    return
  end
  local maxAnimLen = -1
  local bossObj = self:GetBossObjByModelStr(modelStr)
  if bossObj and not UILuaHelper.IsNull(bossObj) then
    UILuaHelper.PlayAnimatorByNameInChildren(bossObj, animTab.boss)
    local tempAnimLen = UILuaHelper.GetAnimatorLengthByNameInChildren(bossObj, animTab.boss)
    if maxAnimLen < tempAnimLen then
      maxAnimLen = tempAnimLen
    end
  end
  local bossCameraObj = self:GetBossCameraByModelStr(modelStr)
  if bossCameraObj and not UILuaHelper.IsNull(bossCameraObj) then
    UILuaHelper.PlayAnimatorByNameInChildren(bossCameraObj, animTab.camera)
    local tempAnimLen = UILuaHelper.GetAnimatorLengthByNameInChildren(bossCameraObj, animTab.camera)
    if maxAnimLen < tempAnimLen then
      maxAnimLen = tempAnimLen
    end
  end
  local lightObj = self:GetBossLightObjByModelStr(modelStr)
  if lightObj and not UILuaHelper.IsNull(lightObj) then
    UILuaHelper.PlayAnimatorByNameInChildren(lightObj, animTab.light)
    local tempAnimLen = UILuaHelper.GetAnimatorLengthByNameInChildren(lightObj, animTab.light)
    if maxAnimLen < tempAnimLen then
      maxAnimLen = tempAnimLen
    end
  end
  return maxAnimLen
end

return BossModule
