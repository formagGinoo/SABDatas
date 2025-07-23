local BaseManager = require("Manager/Base/BaseManager")
local GMManager = class("GMManager", BaseManager)
local json = require("common/json")

function GMManager:OnCreate()
  self.m_allZoneList = nil
  self.m_isAbleDebugger = nil
  self.m_isEditor = nil
  self.m_keyBoard_time = 0
  self.m_f1Trigger_time = 0
  self.m_openKeyBoard = false
  if UILuaHelper.IsAbleDebugger() then
    self:InitTestInitLangTxt()
  end
end

function GMManager:OnInitNetwork()
  if not CS.ApplicationManager.Instance:IsEnableDebugNova() then
    return
  end
  if not UILuaHelper.IsAbleDebugger() then
    return
  end
  URLManager:GetStrFromURL("http://gm.nova.oa.mt:8200/index.php?mod=GmTools/zonelist", handler(self, self.OnGetServerZoneListBack))
  self:GMShowUserBaseInfo()
  self:CheckShowPassLevel()
  self:CheckUnlockAllSystem()
  self:GMSetEasyAccount()
  self:GMSetUIDestroyMode()
  self:GMEnterHitMole()
  self:GmGuaranteesTips()
  self.m_isAbleDebugger = UILuaHelper.IsAbleDebugger()
  self.m_isEditor = CS.UnityEngine.Application.isEditor
  RPCS():Listen_Push_GM_DailyRefresh(handler(self, self.OnPushGMDailyRefresh), "GMManager")
end

function GMManager:OnPushGMDailyRefresh()
  GameManager:dailyReset()
end

function GMManager:OnUpdate(dt)
  if self.m_isAbleDebugger and self.m_isEditor then
    self.m_keyBoard_time = self.m_keyBoard_time + dt
    if self.m_f1Trigger_time > 0 then
      self.m_f1Trigger_time = self.m_f1Trigger_time - dt
    end
    if self.m_openKeyBoard and self.m_keyBoard_time > 0.2 then
      if U3DUtil and U3DUtil:Input_GetKeyDown("w") then
        LUA_RELOAD_DEBUG = true
        CS.UI.UILuaHelper.SetLuaReloadDeBug(LUA_RELOAD_DEBUG)
        self.m_keyBoard_time = 0
        StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, "开启perfab debug模式")
      end
      if U3DUtil and U3DUtil:Input_GetKeyDown("q") then
        LUA_RELOAD_DEBUG = false
        CS.UI.UILuaHelper.SetLuaReloadDeBug(LUA_RELOAD_DEBUG)
        self.m_keyBoard_time = 0
        StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, "关闭perfab debug模式")
      end
      if U3DUtil and U3DUtil:Input_GetKeyDown("2") then
        CS.UnityEngine.Time.timeScale = 2
        UILuaHelper.SetBattleSpeed(2)
        self.m_keyBoard_time = 0
        StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, "开启全局2倍速")
      end
      if U3DUtil and U3DUtil:Input_GetKeyDown("1") then
        CS.UnityEngine.Time.timeScale = 1
        UILuaHelper.SetBattleSpeed(1)
        self.m_keyBoard_time = 0
        StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, "恢复1倍速")
      end
      if U3DUtil and U3DUtil:Input_GetKeyDown("-") then
        self.m_openKeyBoard = false
        self.m_keyBoard_time = 0
        StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, "关闭键盘快捷键模式")
      end
    end
    if self.m_keyBoard_time > 0.2 then
      if U3DUtil and U3DUtil:Input_GetKeyDown("`") then
        StackTop:Push(UIDefines.ID_FORM_GMNEW)
      end
      if U3DUtil and U3DUtil:Input_GetKeyUp("`") then
        StackTop:RemoveUIFromStack(UIDefines.ID_FORM_GMNEW)
        self.m_keyBoard_time = 0
      end
      if U3DUtil and U3DUtil:Input_GetKeyDown("+") then
        UILuaHelper.ShowSRDebugPanel()
        self.m_keyBoard_time = 0
      end
      if U3DUtil and U3DUtil:Input_GetKeyDown("F1") then
        if self.m_f1Trigger_time > 0 then
          CS.Util.ReloadTables(ConfigManager.m_mConfigInstanceCache)
          StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, "表格已重载")
          self.m_keyBoard_time = 0
          self.m_f1Trigger_time = 0
        else
          self.m_f1Trigger_time = 2.0
        end
      end
    end
    if not self.m_openKeyBoard and self.m_keyBoard_time > 0.2 and U3DUtil and U3DUtil:Input_GetKeyDown("*") then
      self.m_openKeyBoard = true
      self.m_keyBoard_time = 0
      StackTop:Push(UIDefines.ID_FORM_COMMON_TOAST, "开启键盘快捷键模式")
    end
    if self.m_keyBoard_time > 20 then
      self.m_keyBoard_time = 0.2
    end
  end
end

function GMManager:GetServerList()
  URLManager:GetStrFromURL("http://gm.nova.oa.mt:8200/index.php?mod=GmTools/zonelist", handler(self, self.OnGetServerZoneListBack))
end

function GMManager:OnGetServerZoneListBack(jsonStr)
  if not jsonStr then
    return
  end
  local splitStrList = string.split(jsonStr, ">")
  local allZoneData = json.decode(splitStrList[2])
  self.m_allZoneList = allZoneData
  self:CheckAddGMServer()
end

function GMManager:CheckAddGMServer()
  if not self.m_allZoneList then
    return
  end
  if not UILuaHelper.IsAbleDebugger() then
    return
  end
  for index, zoneInfo in ipairs(self.m_allZoneList) do
    SROptionsModify.AddSROptionMethod(zoneInfo.fname, function()
      self:OnGmServerChangeBack(index)
    end, "服务器列表", 0)
  end
end

function GMManager:OnGmServerChangeBack(index)
  if not index then
    return
  end
  if not self.m_allZoneList then
    return
  end
  local zoneInfo = self.m_allZoneList[index]
  if not zoneInfo then
    return
  end
  local changeZoneID = zoneInfo.id
  local curZoneID = UserDataManager:GetZoneID()
  if changeZoneID == curZoneID then
    log.info("GMManager ChangeZone 和当前是一致的不需要更换")
    return
  end
  local curAccountID = UserDataManager:GetAccountID()
  Util.RequestGM(curZoneID, "change_zone " .. curAccountID .. " " .. changeZoneID)
  ApplicationManager:RestartGame()
end

function GMManager:CheckShowPassLevel()
  SROptionsModify.AddSROptionMethod("通过当前主线关卡", function()
    self:OnPassNextLevelBack()
  end, "Debug", 0)
end

function GMManager:OnPassNextLevelBack()
  local levelMainHelper = LevelManager:GetLevelMainHelper()
  if not levelMainHelper then
    return
  end
  local nextLevelInfo = levelMainHelper:GetNextShowLevelCfg(LevelManager.MainLevelSubType.MainStory)
  if not nextLevelInfo then
    return
  end
  local nextLevelID = nextLevelInfo.m_LevelID
  local curZoneID = UserDataManager:GetZoneID()
  local curAccountID = UserDataManager:GetAccountID()
  Util.RequestGM(curZoneID, "pass_stage_main " .. curAccountID .. " " .. nextLevelID)
end

function GMManager:CheckUnlockAllSystem()
  SROptionsModify.AddSROptionMethod("解锁所有系统功能", function()
    self:OnUnlockAllSystemBack()
  end, "Debug", 0)
end

function GMManager:OnUnlockAllSystemBack()
  local curZoneID = UserDataManager:GetZoneID()
  local curAccountID = UserDataManager:GetAccountID()
  Util.RequestGM(curZoneID, "pass_all_stage_main " .. curAccountID)
  GuideManager:SkipGuide()
  Util.RequestGM(curZoneID, "set_level " .. curAccountID .. " " .. 50)
end

function GMManager:GMSetEasyAccount()
  SROptionsModify.AddSROptionMethod("设置一个成品号", function()
    self:OnSetEasyAccount()
  end, "Debug", 0)
end

function GMManager:GMEnterHitMole()
  SROptionsModify.AddSROptionMethod("打地鼠", function()
    StackFlow:Push(UIDefines.ID_FORM_WHACKMOLEBATTLEMAIN, {
      iSubActId = 1036,
      iLevelID = 6,
      iActId = 1030
    })
  end, "Debug", 0)
end

function GMManager:GmGuaranteesTips()
  SROptionsModify.AddSROptionMethod("保底弹窗", function()
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginProtocolHandlingFail"),
      bLockBack = 2,
      btnNum = 1,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end, "Debug", 0)
end

function GMManager:OnSetEasyAccount()
  local curZoneID = UserDataManager:GetZoneID()
  local curAccountID = UserDataManager:GetAccountID()
  GuideManager:SkipGuide()
  Util.RequestGM(curZoneID, "pass_to_stage " .. curAccountID .. " 1 " .. 1103050)
  Util.RequestGM(curZoneID, "set_level " .. curAccountID .. " " .. 50)
  Util.RequestGM(curZoneID, "add_item " .. curAccountID .. " 101 " .. 99999999)
  Util.RequestGM(curZoneID, "add_item " .. curAccountID .. " 999 " .. 99999999)
  Util.RequestGM(curZoneID, "add_item " .. curAccountID .. " 1001 " .. 99999999)
  Util.RequestGM(curZoneID, "add_item " .. curAccountID .. " 1002 " .. 99999999)
  Util.RequestGM(curZoneID, "add_all_equip " .. curAccountID)
  Util.RequestGM(curZoneID, "add_all_item " .. curAccountID)
end

function GMManager:GMSetUIDestroyMode()
  SROptionsModify.AddSROptionMethod("UI自毁模式", function()
    LUA_RELOAD_DEBUG = true
    CS.UI.UILuaHelper.SetLuaReloadDeBug(LUA_RELOAD_DEBUG)
  end, "Debug", 0)
end

function GMManager:InitTestInitLangTxt()
  SROptionsModify.AddSROptionMethod("PopAll", function()
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("StartCheckNetworkFail"),
      btnNum = 2,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      func1 = function()
      end,
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonExit"),
      func2 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("InitMSDKInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("InitMSDKAccountInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("InitMSDKGetAccountInfoFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRestart"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
      end,
      func2 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonPrompt"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeForce"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonDownload"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonPrompt"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeWindowsForce"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonDownload"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeVersionErrorTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LogicCheckUpgradeVersionErrorDesc"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonExit"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneDescMatch"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeChangeZoneDescNoMatch"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginCheckUpgradeDownloadFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LowStorageWarning"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginMiniPatchUpgradeDownloadFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectGameServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
      end,
      func2 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginRoleInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
      end,
      func2 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginRoleBanTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LoginRoleBanDesc"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("LoginRoleBanChangeAccount"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("LoginRoleBanCustomer"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
      end,
      func2 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginRoleInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
      end,
      func2 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("DataAnonymFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LowStorageWarning"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceNewbieDesc"),
      bUpdateContent = true,
      contentAlign = CS.TMPro.TextAlignmentOptions.Left,
      fContentCB = function(sContent)
        local sContentNew = sContent .. "\n" .. CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceMobilePrompt")
        return sContentNew
      end,
      fAutoConfirmDelay = 10,
      fRefreshAutoConfirmCB = function()
        return false
      end,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 3,
      bLockBack = true,
      func1 = function(bAutoConfirm)
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTitle"),
      content = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceBasicDesc"),
      bUpdateContent = true,
      contentAlign = CS.TMPro.TextAlignmentOptions.Left,
      fContentCB = function(sContent)
        local sContentNew = sContent .. "\n" .. CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceMobilePrompt")
        return sContentNew
      end,
      fAutoConfirmDelay = 10,
      fRefreshAutoConfirmCB = function()
        return false
      end,
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 3,
      bLockBack = true,
      func1 = function(bAutoConfirm)
      end
    })
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonConfirm"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
      end
    })
  end, "TestInitLangTxt", 100)
end

function GMManager:GMShowUserBaseInfo()
  local category = "用户账号信息"
  local accountID = UserDataManager:GetAccountID()
  local accountName = UserDataManager:GetAccountName()
  local userName = RoleManager:GetName()
  local zoneID = UserDataManager:GetZoneID()
  local zoneName = UserDataManager:GetZoneName()
  local showZoneStr = zoneName .. "-" .. zoneID
  local androidId = UserDataManager:GetAndroidID()
  SROptionsModify.AddSROptionParam("账号accountID：", accountID, category)
  SROptionsModify.AddSROptionParam("账号accountName：", accountName, category)
  SROptionsModify.AddSROptionParam("用户名userName：", userName, category)
  SROptionsModify.AddSROptionParam("区服zoneName-zoneID：", showZoneStr, category)
  SROptionsModify.AddSROptionParam("AndroId:", androidId, category)
end

return GMManager
