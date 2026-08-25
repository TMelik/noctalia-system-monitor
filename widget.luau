--!nonstrict

local MIB = 1024 * 1024
local NETWORK_MEGABYTE = 1000000

local THRESHOLD_DEFAULTS = {
  cpu_usage = { 50, 90 }, cpu_temp = { 60, 85 },
  gpu_usage = { 50, 95 }, gpu_temp = { 60, 85 }, gpu_vram = { 50, 90 },
  ram_pct = { 60, 90 }, swap_pct = { 20, 80 }, disk_used_pct = { 80, 95 },
  net_rx = { 1, 50 }, net_tx = { 1, 50 },
}

local function trim(value)
  if type(value) ~= "string" then return "" end
  return string.match(value, "^%s*(.-)%s*$") or ""
end

local function formatPercent(value)
  if type(value) ~= "number" then return "—" end
  return string.format("%.0f%%", value)
end

local function formatTemperature(value)
  if type(value) ~= "number" then return "—" end
  return string.format("%.0f°C", value)
end

local function formatBinary(bytes)
  if type(bytes) ~= "number" or bytes < 0 then return "—" end
  local units = { "B", "K", "M", "G", "T", "P" }
  local index = 1
  local scaled = bytes
  while scaled >= 1024 and index < #units do
    scaled = scaled / 1024
    index = index + 1
  end
  if index == 1 or scaled >= 10 then
    return string.format("%.0f%s", scaled, units[index])
  end
  return string.format("%.1f%s", scaled, units[index])
end

local function formatRate(value, compact)
  if type(value) ~= "number" then return "—" end
  if value >= 1000000000 then
    return string.format(compact and "%.1fG/s" or "%.1f GB/s", value / 1000000000)
  elseif value >= 1000000 then
    return string.format(compact and "%.1fM/s" or "%.1f MB/s", value / 1000000)
  elseif value >= 1000 then
    return string.format(compact and "%.1fk/s" or "%.1f kB/s", value / 1000)
  end
  return string.format(compact and "%.0fB/s" or "%.0f B/s", value)
end

local function formatFrequency(value)
  if type(value) ~= "number" then return "—" end
  return string.format("%.1f GHz", value / 1000)
end

local function formatLoad(loadAvg)
  if type(loadAvg) ~= "table" or type(loadAvg[1]) ~= "number"
      or type(loadAvg[2]) ~= "number" or type(loadAvg[3]) ~= "number" then
    return "—"
  end
  return string.format("%.2f · %.2f · %.2f", loadAvg[1], loadAvg[2], loadAvg[3])
end

local function configBool(key, fallback)
  local value = noctalia.getConfig(key)
  if type(value) == "boolean" then return value end
  return fallback
end

local function configString(key, fallback)
  local value = noctalia.getConfig(key)
  if type(value) == "string" then return value end
  return fallback
end

local function configColor(key, fallback)
  local value = configString(key, fallback)
  if trim(value) == "" then return fallback end
  return value
end

local function configSelect(key, fallback)
  local value = noctalia.getConfig(key)
  if value == "percentage" or value == "used" or value == "available" then return value end
  return fallback
end

local function percentage(used, total)
  if type(used) ~= "number" or type(total) ~= "number" or total <= 0 then return nil end
  return used / total * 100
end

local function thresholdPair(name)
  local defaults = THRESHOLD_DEFAULTS[name]
  local activity = noctalia.getSetting("system.monitor." .. name .. "_activity_threshold")
  local critical = noctalia.getSetting("system.monitor." .. name .. "_critical_threshold")
  if type(activity) ~= "number" or type(critical) ~= "number"
      or activity < 0 or critical < 0 or activity > critical then
    return defaults[1], defaults[2]
  end
  return activity, critical
end

local function metricColor(value, thresholds, colors)
  if not colors.highlightValues or type(value) ~= "number" or thresholds[2] == 0 then return nil end
  if value >= thresholds[2] then return colors.criticalColor end
  if value >= thresholds[1] then return colors.activityColor end
  return nil
end

local function appendDivider(children)
  local mark = barWidget.isVertical() and "─" or "│"
  table.insert(children, ui.label({ text = mark, color = "outline", fontWeight = "light" }))
end

local function appendGroup(children, group, showSeparators)
  if #group == 0 then return end
  if #children > 0 and showSeparators then appendDivider(children) end
  for _, child in ipairs(group) do table.insert(children, child) end
end

local function appendMetric(group, glyph, text, value, thresholds, colors, highlightValue)
  if value == nil and colors.hideUnavailable then return false end
  local color = metricColor(highlightValue, thresholds, colors)
  table.insert(group, ui.glyph({ name = glyph, size = 14, color = color }))
  table.insert(group, ui.label({ text = text, fontWeight = "medium", color = color }))
  return true
end

local function renderFallback(glyph, label, tooltip, showTooltip)
  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({ gap = 4, align = "center" }, {
    ui.glyph({ name = glyph, size = 14 }),
    ui.label({ text = label, fontWeight = "medium" }),
  }))
  if showTooltip then barWidget.setTooltip(tooltip) else barWidget.clearTooltip() end
end

local function ramDisplay(ram, mode)
  if type(ram) ~= "table" then return nil, "—" end
  local usedMb = ram.usedMb
  local totalMb = ram.totalMb
  if mode == "used" then
    return usedMb, formatBinary(type(usedMb) == "number" and usedMb * MIB or nil)
  elseif mode == "available" then
    local availableMb = nil
    if type(totalMb) == "number" and type(usedMb) == "number" then
      availableMb = math.max(0, totalMb - usedMb)
    end
    return availableMb, formatBinary(availableMb and availableMb * MIB or nil)
  end
  return ram.usagePercent, formatPercent(ram.usagePercent)
end

local function diskDisplay(disk, mode)
  if type(disk) ~= "table" then return nil, "—" end
  if mode == "used" then
    local usedBytes = nil
    if type(disk.totalBytes) == "number" and type(disk.freeBytes) == "number" then
      usedBytes = math.max(0, disk.totalBytes - disk.freeBytes)
    end
    return usedBytes, formatBinary(usedBytes)
  elseif mode == "available" then
    return disk.availableBytes, formatBinary(disk.availableBytes)
  end
  return disk.usagePercent, formatPercent(disk.usagePercent)
end

local function addTooltipRow(rows, shown, key, value)
  if shown then table.insert(rows, { key = key, value = value }) end
end

local function formatUsageAmounts(usagePercent, usedBytes, totalBytes)
  return string.format("%s · %s / %s", formatPercent(usagePercent),
    formatBinary(usedBytes), formatBinary(totalBytes))
end

function update()
  noctalia.setUpdateInterval(1000)

  local settings = {
    showCpuUsage = configBool("show_cpu_usage", true),
    showCpuTemperature = configBool("show_cpu_temperature", true),
    showGpuUsage = configBool("show_gpu_usage", false),
    showGpuTemperature = configBool("show_gpu_temperature", false),
    showGpuVram = configBool("show_gpu_vram", false),
    showRam = configBool("show_ram", true), showSwap = configBool("show_swap", true),
    showDisk = configBool("show_disk", true), showDownload = configBool("show_download", true),
    showUpload = configBool("show_upload", true), showSeparators = configBool("show_separators", true),
    showTooltip = configBool("show_tooltip", true), compactNetwork = configBool("compact_network", true),
    highlightValues = configBool("highlight_values", true), hideUnavailable = configBool("hide_unavailable", false),
    activityColor = configColor("activity_color", "primary"), criticalColor = configColor("critical_color", "error"),
    networkInterface = trim(configString("network_interface", "")),
    ramDisplayMode = configSelect("ram_display_mode", "percentage"),
    diskDisplayMode = configSelect("disk_display_mode", "percentage"),
    diskPath = trim(configString("disk_path", "/")),
  }
  if settings.diskPath == "" then settings.diskPath = "/" end

  local thresholds = {}
  for name, _defaults in pairs(THRESHOLD_DEFAULTS) do
    local activity, critical = thresholdPair(name)
    thresholds[name] = { activity, critical }
  end

  local enabledCount = 0
  for _, enabled in ipairs({ settings.showCpuUsage, settings.showCpuTemperature,
      settings.showGpuUsage, settings.showGpuTemperature, settings.showGpuVram,
      settings.showRam, settings.showSwap, settings.showDisk,
      settings.showDownload, settings.showUpload }) do
    if enabled then enabledCount = enabledCount + 1 end
  end
  if enabledCount == 0 then
    renderFallback("adjustments", "No metrics", "Enable at least one metric in the widget settings.", settings.showTooltip)
    return
  end

  local stats = noctalia.systemStats()
  if stats == nil then
    renderFallback("cpu", "System data unavailable",
      "System monitoring is disabled or no sample is available yet.", settings.showTooltip)
    return
  end

  local disk = settings.showDisk and noctalia.diskStats(settings.diskPath) or nil
  local gpu = type(stats.gpu) == "table" and stats.gpu or {}
  local ram = type(stats.ram) == "table" and stats.ram or {}
  local swap = type(stats.swap) == "table" and stats.swap or {}
  local cpu = type(stats.cpu) == "table" and stats.cpu or {}
  local net = type(stats.net) == "table" and stats.net or {}
  local selectedNet = net
  local networkLabel = "Network"
  if settings.networkInterface ~= "" then
    networkLabel = "Network (" .. settings.networkInterface .. ")"
    selectedNet = type(net.interfaces) == "table" and net.interfaces[settings.networkInterface] or nil
    if type(selectedNet) ~= "table" then selectedNet = {} end
  end

  local cpuUsage, cpuTemp = cpu.usagePercent, cpu.tempC
  local gpuUsage, gpuTemp = gpu.usagePercent, gpu.tempC
  local gpuVram = percentage(gpu.vramUsedBytes, gpu.vramTotalBytes)
  local ramUsage = ram.usagePercent
  local swapUsage = percentage(swap.usedMb, swap.totalMb)
  local diskUsage = disk and disk.usagePercent or nil
  local rx, tx = selectedNet.rxBytesPerSec, selectedNet.txBytesPerSec
  local ramValue, ramText = ramDisplay(ram, settings.ramDisplayMode)
  local diskValue, diskText = diskDisplay(disk, settings.diskDisplayMode)

  local colors = { highlightValues = settings.highlightValues, hideUnavailable = settings.hideUnavailable,
    activityColor = settings.activityColor, criticalColor = settings.criticalColor }
  local children, processor, graphics, memory, storage, network = {}, {}, {}, {}, {}, {}
  local shown = {}

  if settings.showCpuUsage then shown.cpuUsage = appendMetric(processor, "cpu", formatPercent(cpuUsage), cpuUsage, thresholds.cpu_usage, colors, cpuUsage) end
  if settings.showCpuTemperature then shown.cpuTemperature = appendMetric(processor, "temperature", formatTemperature(cpuTemp), cpuTemp, thresholds.cpu_temp, colors, cpuTemp) end
  if settings.showGpuUsage then shown.gpuUsage = appendMetric(graphics, "device-desktop", formatPercent(gpuUsage), gpuUsage, thresholds.gpu_usage, colors, gpuUsage) end
  if settings.showGpuTemperature then shown.gpuTemperature = appendMetric(graphics, "temperature", formatTemperature(gpuTemp), gpuTemp, thresholds.gpu_temp, colors, gpuTemp) end
  if settings.showGpuVram then shown.gpuVram = appendMetric(graphics, "memory", formatPercent(gpuVram), gpuVram, thresholds.gpu_vram, colors, gpuVram) end
  if settings.showRam then shown.ram = appendMetric(memory, "server-2", ramText, ramValue, thresholds.ram_pct, colors, ramUsage) end
  if settings.showSwap then shown.swap = appendMetric(memory, "arrows-exchange", formatPercent(swapUsage), swapUsage, thresholds.swap_pct, colors, swapUsage) end
  if settings.showDisk then shown.disk = appendMetric(storage, "database", diskText, diskValue, thresholds.disk_used_pct, colors, diskUsage) end
  if settings.showDownload then shown.download = appendMetric(network, "arrow-down", formatRate(rx, settings.compactNetwork), rx, thresholds.net_rx, colors, rx and rx / NETWORK_MEGABYTE or nil) end
  if settings.showUpload then shown.upload = appendMetric(network, "arrow-up", formatRate(tx, settings.compactNetwork), tx, thresholds.net_tx, colors, tx and tx / NETWORK_MEGABYTE or nil) end

  appendGroup(children, processor, settings.showSeparators)
  appendGroup(children, graphics, settings.showSeparators)
  appendGroup(children, memory, settings.showSeparators)
  appendGroup(children, storage, settings.showSeparators)
  appendGroup(children, network, settings.showSeparators)
  if #children == 0 then
    renderFallback("alert-circle", "No data", "All enabled metrics are currently unavailable.", settings.showTooltip)
    return
  end

  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({ gap = 4, align = "center" }, children))
  if not settings.showTooltip then barWidget.clearTooltip() return end

  local rows = {}
  if shown.cpuUsage or shown.cpuTemperature then
    addTooltipRow(rows, shown.cpuUsage, "CPU usage", formatPercent(cpuUsage))
    addTooltipRow(rows, shown.cpuTemperature, "CPU temperature", formatTemperature(cpuTemp))
    table.insert(rows, { key = "CPU frequency", value = formatFrequency(cpu.freqMhz) })
    table.insert(rows, { key = "Load 1 / 5 / 15", value = formatLoad(stats.loadAvg) })
  end
  if shown.gpuUsage or shown.gpuTemperature or shown.gpuVram then
    addTooltipRow(rows, shown.gpuUsage, "GPU usage", formatPercent(gpuUsage))
    addTooltipRow(rows, shown.gpuTemperature, "GPU temperature", formatTemperature(gpuTemp))
    addTooltipRow(rows, shown.gpuVram, "GPU VRAM",
      formatUsageAmounts(gpuVram, gpu.vramUsedBytes, gpu.vramTotalBytes))
  end
  local ramUsedBytes = type(ram.usedMb) == "number" and ram.usedMb * MIB or nil
  local ramTotalBytes = type(ram.totalMb) == "number" and ram.totalMb * MIB or nil
  local swapUsedBytes = type(swap.usedMb) == "number" and swap.usedMb * MIB or nil
  local swapTotalBytes = type(swap.totalMb) == "number" and swap.totalMb * MIB or nil
  local diskUsedBytes = disk and type(disk.totalBytes) == "number" and type(disk.freeBytes) == "number"
    and math.max(0, disk.totalBytes - disk.freeBytes) or nil
  addTooltipRow(rows, shown.ram, "RAM", formatUsageAmounts(ramUsage, ramUsedBytes, ramTotalBytes))
  addTooltipRow(rows, shown.swap, "Swap", formatUsageAmounts(swapUsage, swapUsedBytes, swapTotalBytes))
  addTooltipRow(rows, shown.disk, "Disk " .. settings.diskPath,
    formatUsageAmounts(diskUsage, diskUsedBytes, disk and disk.totalBytes or nil))
  if shown.download or shown.upload then
    local parts = {}
    if shown.download then table.insert(parts, "RX " .. formatRate(rx, settings.compactNetwork)) end
    if shown.upload then table.insert(parts, "TX " .. formatRate(tx, settings.compactNetwork)) end
    table.insert(rows, { key = networkLabel, value = table.concat(parts, " · ") })
  end
  barWidget.setTooltip(rows)
end
