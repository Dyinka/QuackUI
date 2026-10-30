# CryoHub

Roblox Luau UI library — dark charcoal UI, soft animations, loader, named configs, floating duck toggle.

**Source (raw):**  
https://raw.githubusercontent.com/Lu4ikk1/CryoHubLib/refs/heads/main/CryoLibReBirth

---

## Contents

1. [Features](#features)
2. [Install / Load](#install--load)
3. [Quick start](#quick-start)
4. [CreateLoader](#createloader)
5. [CreateWindow](#createwindow)
6. [Tabs & components](#tabs--components)
7. [Window methods](#window-methods)
8. [Config system](#config-system)
9. [Themes & colors](#themes--colors)
10. [Assets](#assets)
11. [Behavior notes](#behavior-notes)
12. [Full example](#full-example)

---

## Features

- Loader screen with progress bar, floating image, per-step callbacks  
- Main window: drag, minimize, close confirm, toggle key  
- Sidebar tabs with **white underline** selection (hover + active)  
- Components:
  - Toggle  
  - Slider  
  - Button (soft light-up + white underline, **no size growth**)  
  - Textbox  
  - Keybind  
  - Dropdown (popup under trigger, tab-style item underline)  
  - ColorPicker (popup with RGB sliders)  
  - ConfigList (name field + filtered list + Save / Load / Delete)  
- Notifications (bottom-right, slide + scale)  
- Named JSON configs on executor filesystem  
- Floating duck button + header icon (`71109437053861`) with bob / tilt animation  
- Themes: `Charcoal`, `Obsidian`  
- Optional sounds, FPS watermark  
- Window opens **centered** on first launch  

---

## Install / Load

```lua
local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Lu4ikk1/CryoHubLib/refs/heads/main/CryoLibReBirth?t=" .. tostring(tick())
))()
