-- 延后排序学习记录器
-- 只在候选上屏时向 TSV 文件追加一行，不参与候选查询和排序。

local M = {}

local function sanitize(value)
  value = tostring(value or "")
  return value:gsub("[\t\r\n]", " ")
end

local function user_data_path(filename)
  local base = rime_api.get_user_data_dir()
  if not base or base == "" then
    return filename
  end
  base = base:gsub("[/\\]+$", "")
  return base .. "/" .. filename
end

local function append_record(env, text, code)
  if not text or text == "" or not code or code == "" then
    return
  end
  if #code > env.max_code_length or not code:match("^[a-z']+$") then
    return
  end

  local file = io.open(env.log_path, "a")
  if not file then
    return
  end

  file:write(os.time(), "\t", sanitize(text), "\t", sanitize(code), "\n")
  file:close()
end

function M.init(env)
  local config = env.engine.schema.config
  local namespace = env.name_space or "wubi86_jidian_delayed_learning"
  local filename = config:get_string(namespace .. "/log_file")
      or "wubi86_jidian_delayed_learning.tsv"

  env.max_code_length = config:get_int(namespace .. "/max_code_length") or 32
  env.log_path = user_data_path(filename)
  env.last_input = ""

  env.update_connection = env.engine.context.update_notifier:connect(function(ctx)
    local input = ctx.input
    if input and input ~= "" then
      env.last_input = input
    end
  end)

  env.commit_connection = env.engine.context.commit_notifier:connect(function(ctx)
    local candidate = ctx:get_selected_candidate()
    local text = candidate and candidate.text or ctx:get_commit_text()
    append_record(env, text, env.last_input)
    env.last_input = ""
  end)
end

function M.func(_, _)
  return 2 -- kNoop：完全不拦截按键
end

function M.fini(env)
  if env.update_connection then
    env.update_connection:disconnect()
  end
  if env.commit_connection then
    env.commit_connection:disconnect()
  end
end

return M
