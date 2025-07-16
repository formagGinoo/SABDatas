local utils = require("common/utils")
local path = require("common/path")
local is_windows = path.is_windows
local ldir = path.dir
local mkdir = path.mkdir
local rmdir = path.rmdir
local sub = string.sub
local os, pcall, ipairs, pairs, require, setmetatable = os, pcall, ipairs, pairs, require, _ENV.setmetatable
local remove = os.remove
local append = table.insert
local assert_arg, assert_string, raise = utils.assert_arg, utils.assert_string, utils.raise
local exists, isdir = path.exists, path.isdir
local sep = path.sep
local dir = {}

local function makelist(l)
  return setmetatable(l, require("common/List"))
end

local function assert_dir(n, val)
  assert_arg(n, val, "string", path.isdir, "not a directory", 4)
end

local function filemask(mask)
  mask = utils.escape(path.normcase(mask))
  return "^" .. mask:gsub("%%%*", ".*"):gsub("%%%?", ".") .. "$"
end

function dir.fnmatch(filename, pattern)
  assert_string(1, filename)
  assert_string(2, pattern)
  return path.normcase(filename):find(filemask(pattern)) ~= nil
end

function dir.filter(filenames, pattern)
  assert_arg(1, filenames, "table")
  assert_string(2, pattern)
  local res = {}
  local mask = filemask(pattern)
  for i, f in ipairs(filenames) do
    if path.normcase(f):find(mask) then
      append(res, f)
    end
  end
  return makelist(res)
end

local function _listfiles(dirname, filemode, match)
  local res = {}
  local check = utils.choose(filemode, path.isfile, path.isdir)
  dirname = dirname or "."
  for f in ldir(dirname) do
    if f ~= "." and f ~= ".." then
      local p = path.join(dirname, f)
      if check(p) and (not match or match(f)) then
        append(res, p)
      end
    end
  end
  return makelist(res)
end

function dir.getfiles(dirname, mask)
  dirname = dirname or "."
  assert_dir(1, dirname)
  if mask then
    assert_string(2, mask)
  end
  local match
  if mask then
    mask = filemask(mask)
    
    function match(f)
      return path.normcase(f):find(mask)
    end
  end
  return _listfiles(dirname, true, match)
end

function dir.getdirectories(dirname)
  dirname = dirname or "."
  assert_dir(1, dirname)
  return _listfiles(dirname, false)
end

local alien, ffi, ffi_checked, CopyFile, MoveFile, GetLastError, win32_errors, cmd_tmpfile

local function execute_command(cmd, parms)
  if not cmd_tmpfile then
    cmd_tmpfile = path.tmpname()
  end
  local err = path.is_windows and " > " or " 2> "
  cmd = cmd .. " " .. parms .. err .. utils.quote_arg(cmd_tmpfile)
  local ret = utils.execute(cmd)
  if not ret then
    local err = utils.readfile(cmd_tmpfile):gsub([[

(.*)]], "")
    remove(cmd_tmpfile)
    return false, err
  else
    remove(cmd_tmpfile)
    return true
  end
end

local function find_ffi_copyfile()
  if not ffi_checked then
    ffi_checked = true
    local res
    res, alien = pcall(require, "alien")
    if not res then
      alien = nil
      res, ffi = pcall(require, "ffi")
    end
    if not res then
      ffi = nil
      return
    end
  else
    return
  end
  if alien then
    local kernel = alien.load("kernel32.dll")
    CopyFile = kernel.CopyFileA
    CopyFile:types({
      "string",
      "string",
      "int",
      ret = "int",
      abi = "stdcall"
    })
    MoveFile = kernel.MoveFileA
    MoveFile:types({
      "string",
      "string",
      ret = "int",
      abi = "stdcall"
    })
    GetLastError = kernel.GetLastError
    GetLastError:types({ret = "int", abi = "stdcall"})
  elseif ffi then
    ffi.cdef([[
            int CopyFileA(const char *src, const char *dest, int iovr);
            int MoveFileA(const char *src, const char *dest);
            int GetLastError();
        ]])
    CopyFile = ffi.C.CopyFileA
    MoveFile = ffi.C.MoveFileA
    GetLastError = ffi.C.GetLastError
  end
  win32_errors = {
    ERROR_FILE_NOT_FOUND = 2,
    ERROR_PATH_NOT_FOUND = 3,
    ERROR_ACCESS_DENIED = 5,
    ERROR_WRITE_PROTECT = 19,
    ERROR_BAD_UNIT = 20,
    ERROR_NOT_READY = 21,
    ERROR_WRITE_FAULT = 29,
    ERROR_READ_FAULT = 30,
    ERROR_SHARING_VIOLATION = 32,
    ERROR_LOCK_VIOLATION = 33,
    ERROR_HANDLE_DISK_FULL = 39,
    ERROR_BAD_NETPATH = 53,
    ERROR_NETWORK_BUSY = 54,
    ERROR_DEV_NOT_EXIST = 55,
    ERROR_FILE_EXISTS = 80,
    ERROR_OPEN_FAILED = 110,
    ERROR_INVALID_NAME = 123,
    ERROR_BAD_PATHNAME = 161,
    ERROR_ALREADY_EXISTS = 183
  }
end

local function two_arguments(f1, f2)
  return utils.quote_arg(f1) .. " " .. utils.quote_arg(f2)
end

local function file_op(is_copy, src, dest, flag)
  if flag == 1 and path.exists(dest) then
    return false, "cannot overwrite destination"
  end
  if is_windows then
    find_ffi_copyfile()
    if not CopyFile then
      if path.is_windows then
        src = src:gsub("/", "\\")
        dest = dest:gsub("/", "\\")
      end
      local res, err = execute_command("copy", two_arguments(src, dest))
      if not res then
        return false, err
      end
      if not is_copy then
        return execute_command("del", utils.quote_arg(src))
      end
      return true
    else
      if path.isdir(dest) then
        dest = path.join(dest, path.basename(src))
      end
      local ret
      if is_copy then
        ret = CopyFile(src, dest, flag)
      else
        ret = MoveFile(src, dest)
      end
      if ret == 0 then
        local err = GetLastError()
        for name, value in pairs(win32_errors) do
          if value == err then
            return false, name
          end
        end
        return false, "Error #" .. err
      else
        return true
      end
    end
  else
    return execute_command(is_copy and "cp" or "mv", two_arguments(src, dest))
  end
end

function dir.copyfile(src, dest, flag)
  assert_string(1, src)
  assert_string(2, dest)
  flag = flag == nil or flag
  return file_op(true, src, dest, flag and 0 or 1)
end

function dir.movefile(src, dest)
  assert_string(1, src)
  assert_string(2, dest)
  return file_op(false, src, dest, 0)
end

local function _dirfiles(dirname, attrib)
  local dirs = {}
  local files = {}
  for f in ldir(dirname) do
    if f ~= "." and f ~= ".." then
      local p = path.join(dirname, f)
      local mode = attrib(p, "mode")
      if mode == "directory" then
        append(dirs, f)
      else
        append(files, f)
      end
    end
  end
  return makelist(dirs), makelist(files)
end

function dir.walk(root, bottom_up, follow_links)
  assert_dir(1, root)
  local attrib
  if path.is_windows or not follow_links then
    attrib = path.attrib
  else
    attrib = path.link_attrib
  end
  local to_scan = {root}
  local to_return = {}
  
  local function iter()
    while 0 < #to_scan do
      local current_root = table.remove(to_scan)
      local dirs, files = _dirfiles(current_root, attrib)
      for _, d in ipairs(dirs) do
        table.insert(to_scan, current_root .. path.sep .. d)
      end
      if not bottom_up then
        return current_root, dirs, files
      else
        table.insert(to_return, {
          current_root,
          dirs,
          files
        })
      end
    end
    if 0 < #to_return then
      return utils.unpack(table.remove(to_return))
    end
  end
  
  return iter
end

function dir.rmtree(fullpath)
  assert_dir(1, fullpath)
  if path.islink(fullpath) then
    return false, "will not follow symlink"
  end
  for root, dirs, files in dir.walk(fullpath, true) do
    if path.islink(root) then
      if is_windows then
        local res, err = rmdir(root)
        if not res then
          return nil, err .. ": " .. root
        end
      else
        local res, err = remove(root)
        if not res then
          return nil, err .. ": " .. root
        end
      end
    else
      for i, f in ipairs(files) do
        local res, err = remove(path.join(root, f))
        if not res then
          return nil, err .. ": " .. path.join(root, f)
        end
      end
      local res, err = rmdir(root)
      if not res then
        return nil, err .. ": " .. root
      end
    end
  end
  return true
end

do
  local dirpat
  if path.is_windows then
    dirpat = "(.+)\\[^\\]+$"
  else
    dirpat = "(.+)/[^/]+$"
  end
  local _makepath
  
  function _makepath(p)
    if p:find("^%a:[\\]*$") then
      return true
    end
    if not path.isdir(p) then
      local subp = p:match(dirpat)
      if subp then
        local ok, err = _makepath(subp)
        if not ok then
          return nil, err
        end
      end
      return mkdir(p)
    else
      return true
    end
  end
  
  function dir.makepath(p)
    assert_string(1, p)
    if path.is_windows then
      p = p:gsub("/", "\\")
    end
    return _makepath(path.abspath(p))
  end
end

function dir.clonetree(path1, path2, file_fun, verbose)
  assert_string(1, path1)
  assert_string(2, path2)
  if verbose == true then
    verbose = print
  end
  local abspath, normcase, isdir, join = path.abspath, path.normcase, path.isdir, path.join
  local faildirs, failfiles = {}, {}
  if not isdir(path1) then
    return raise("source is not a valid directory")
  end
  path1 = abspath(normcase(path1))
  path2 = abspath(normcase(path2))
  if verbose then
    verbose("normalized:", path1, path2)
  end
  if path1 == path2 then
    return raise("paths are the same")
  end
  local _, i2 = path2:find(path1, 1, true)
  if i2 == #path1 and path2:sub(i2 + 1, i2 + 1) == path.sep then
    return raise("destination is a subdirectory of the source")
  end
  local cp = path.common_prefix(path1, path2)
  local idx = #cp
  if idx == 0 and path1:sub(2, 2) == ":" then
    idx = 3
  end
  for root, dirs, files in dir.walk(path1) do
    local opath = path2 .. root:sub(idx)
    if verbose then
      verbose("paths:", opath, root)
    end
    if not isdir(opath) then
      local ret = dir.makepath(opath)
      if not ret then
        append(faildirs, opath)
      end
      if verbose then
        verbose("creating:", opath, ret)
      end
    end
    if file_fun then
      for i, f in ipairs(files) do
        local p1 = join(root, f)
        local p2 = join(opath, f)
        local ret = file_fun(p1, p2)
        if not ret then
          append(failfiles, p2)
        end
        if verbose then
          verbose("files:", p1, p2, ret)
        end
      end
    end
  end
  return true, faildirs, failfiles
end

local function treeiter(iterstack)
  local diriter = iterstack[#iterstack]
  if not diriter then
    return
  end
  local dirname = diriter[1]
  local entry = diriter[2](diriter[3])
  if not entry then
    table.remove(iterstack)
    return treeiter(iterstack)
  end
  if entry ~= "." and entry ~= ".." then
    entry = dirname .. sep .. entry
    if exists(entry) then
      local is_dir = isdir(entry)
      if is_dir then
        table.insert(iterstack, {
          entry,
          ldir(entry)
        })
      end
      return entry, is_dir
    end
  end
  return treeiter(iterstack)
end

function dir.dirtree(d)
  assert(d and d ~= "", "directory parameter is missing or empty")
  local last = sub(d, -1)
  if last == sep or last == "/" then
    d = sub(d, 1, -2)
  end
  local iterstack = {
    {
      d,
      ldir(d)
    }
  }
  return treeiter, iterstack
end

function dir.getallfiles(start_path, shell_pattern)
  start_path = start_path or "."
  assert_dir(1, start_path)
  shell_pattern = shell_pattern or "*"
  local files = {}
  local normcase = path.normcase
  for filename, mode in dir.dirtree(start_path) do
    if not mode then
      local mask = filemask(shell_pattern)
      if normcase(filename):find(mask) then
        files[#files + 1] = filename
      end
    end
  end
  return makelist(files)
end

return dir
