local BaseManager = require("Manager/Base/BaseManager")
local DirtyCharManager = class("DirtyCharManager", BaseManager)
local gmatch = string.gfind or string.gmatch

function DirtyCharManager:OnCreate()
  self.m_mDirtyWordChat = {}
  self:_InitTree()
end

function DirtyCharManager:OnInitNetwork()
  local function OnGetDirtyWords(sc, msg)
    self.m_mDirtyWordChat = sc.mDirtyWordChat
  end
  
  local reqMsg = MTTDProto.Cmd_Chat_GetDirtyWords_CS()
  RPCS():Chat_GetDirtyWords(reqMsg, OnGetDirtyWords)
end

function DirtyCharManager:FilterString(str, repChar)
  if repChar == nil then
    repChar = "*"
  end
  if self.m_treeRoot == nil then
    return false, str
  end
  local hasDirty = false
  local filterStr = str
  local node = self.m_treeRoot
  local childNode
  local dirtyWord = ""
  local dirtyWordCheck = ""
  local dirtyLth = 0
  local dirtyLthCheck = 0
  local replaceWord = ""
  local replaceWordCheck = ""
  local isCharStartCheck = false
  local charIndex = 0
  local strLth = #str
  if 0 < strLth then
    while charIndex < strLth do
      local charBytes = string.utf8charbytes(str, charIndex + 1)
      local strChar = string.sub(str, charIndex + 1, charIndex + charBytes)
      charIndex = charIndex + charBytes
      childNode = self:GetChild(node, strChar)
      if childNode == nil and strChar ~= " " then
        if 0 < dirtyLthCheck then
          local bCheck
          bCheck, filterStr = self:_Replace(filterStr, dirtyWordCheck, replaceWordCheck, isCharStartCheck, false)
          if bCheck then
            hasDirty = true
          end
        end
        dirtyWordCheck = ""
        dirtyWord = ""
        replaceWord = ""
        replaceWordCheck = ""
        dirtyLthCheck = 0
        dirtyLth = 0
        isCharStartCheck = false
        node = self.m_treeRoot
        childNode = self:GetChild(node, strChar)
      end
      if childNode then
        dirtyWord = dirtyWord .. strChar
        replaceWord = replaceWord .. repChar
        dirtyLth = dirtyLth + 1
        if childNode.isEnd then
          local isCharStart = charIndex == dirtyLth
          local isCharEnd = charIndex == strLth
          if isCharEnd then
            local bCheck
            bCheck, filterStr = self:_Replace(filterStr, dirtyWord, replaceWord, isCharStart, isCharEnd)
            if bCheck then
              hasDirty = true
            end
            dirtyWordCheck = ""
            dirtyWord = ""
            replaceWord = ""
            replaceWordCheck = ""
            dirtyLthCheck = 0
            dirtyLth = 0
            isCharStart = false
          else
            dirtyWordCheck = dirtyWord
            replaceWordCheck = replaceWord
            dirtyLthCheck = dirtyLth
            isCharStartCheck = isCharStart
          end
        end
        node = childNode
      elseif strChar == " " and 0 < #dirtyWord then
        dirtyWord = dirtyWord .. strChar
        replaceWord = replaceWord .. strChar
        dirtyLth = dirtyLth + 1
      end
    end
  end
  return hasDirty, filterStr
end

function DirtyCharManager:_InitTree()
  if self.m_treeRoot ~= nil then
    return
  end
  local dirtyWorldAry = require("Doc/DirtyChar")
  local lth = #dirtyWorldAry
  for i, v in pairs(self.m_mDirtyWordChat) do
    if v == 1 then
      dirtyWorldAry[lth + 1] = i
      lth = lth + 1
    end
  end
  if dirtyWorldAry == nil or #dirtyWorldAry <= 0 then
    return
  end
  log.info("DirtyCharManager:_InitTree start:" .. os.clock())
  self.m_treeRoot = {}
  self.m_treeRoot.value = ""
  local lth = #dirtyWorldAry
  for index = 1, lth do
    local word = dirtyWorldAry[index]
    local charIndex = 0
    local wordLth = #word
    if (self.m_mDirtyWordChat[word] == nil or self.m_mDirtyWordChat[word] == 1) and 0 < wordLth then
      local node = self.m_treeRoot
      while charIndex < wordLth do
        local charBytes = string.utf8charbytes(word, charIndex + 1)
        local strChar = string.sub(word, charIndex + 1, charIndex + charBytes)
        charIndex = charIndex + charBytes
        local tempNode = self:GetChild(node, strChar)
        if tempNode then
          node = tempNode
        else
          node = self:AddChild(node, strChar)
        end
      end
      node.isEnd = true
    end
  end
  log.info("DirtyCharManager:_InitTree end:" .. os.clock())
end

function DirtyCharManager:_Replace(srcString, patternString, repString, isCharStart, isCharEnd)
  local tmp_patternString = patternString:gsub("%s+", "")
  if string.find(tmp_patternString, "%A") == nil then
    if isCharStart and isCharEnd then
      return true, repString
    elseif isCharStart then
      local pattern = patternString .. "%A"
      if string.find(srcString, pattern) then
        for w in gmatch(srcString, pattern) do
          local wnew = string.gsub(w, patternString, repString)
          srcString = string.gsub(srcString, w, wnew, 1)
          break
        end
        return true, srcString
      end
    elseif isCharEnd then
      local pattern = "%A" .. patternString .. "$"
      if string.find(srcString, pattern) then
        for w in gmatch(srcString, pattern) do
          local wnew = string.gsub(w, patternString, repString)
          srcString = string.gsub(srcString, w, wnew, 1)
          break
        end
        return true, srcString
      end
    else
      local pattern = "%A" .. patternString .. "%A"
      if string.find(srcString, pattern) then
        for w in gmatch(srcString, pattern) do
          local wnew = string.gsub(w, patternString, repString)
          srcString = string.gsub(srcString, w, wnew, 1)
          break
        end
        return true, srcString
      end
    end
  else
    srcString = string.gsub(srcString, patternString, repString, 1)
    return true, srcString
  end
  return false, srcString
end

function DirtyCharManager:GetChild(node, char)
  if node.children ~= nil then
    return node.children[char]
  end
  return nil
end

function DirtyCharManager:AddChild(node, char)
  local child = {}
  child.isEnd = false
  child.value = char
  child.parentNode = node
  node.children = node.children or {}
  node.children[char] = child
  return child
end

function DirtyCharManager:_CheckSpecialChar(iMessageType, srcString)
  if iMessageType == MTTDProto.DirtyCheckMessageType_Name then
    local pattern = "[%$%%%{%}%[%]|]"
    local replacement = "*"
    local newText = string.gsub(srcString, pattern, replacement)
    srcString = newText
    local hasDirty, filterStr = DirtyCharManager:FilterString(srcString)
    if hasDirty then
      srcString = filterStr
    end
  end
  return srcString
end

return DirtyCharManager
