# Zhou Yan Desktop Pet

周延独立桌宠资产，单独提供 Codex、macOS 和 Windows 版本。

## 版本

- `zhou-yan/codex-pet/`：Codex v2 资产。
- `zhou-yan/macOS/`：macOS 通用版应用、源码和资源。
- `zhou-yan/Windows/`：Windows 桌宠、启动文件和资源。
- `releases/`：macOS 与 Windows 压缩包。

## Codex 说明

周延保持与 GAI 一致的 2.5 头身比例。Codex 图集加入关键帧保持以降低跳帧感；需要授权使用 waiting，思考使用 failed，failed 使用 waving。Codex 图集为独立资产，不修改 GAI 宠物。

## 独立版动作逻辑

idle 完整循环 6 次后固定播放 singing → waiting → failed，每个动作完整循环 3 次；悬停触发连续说唱，靠近但未悬停时触发 16 方向注视，左右拖拽即时切换跑步方向，悬停说唱累计 3 次或拖拽累计超过 7 秒后触发生气。

## 启动

- macOS：双击 `zhou-yan/macOS/ZhouYanDesktopPet.app`。
- Windows：安装 Python 3 后双击 `zhou-yan/Windows/start-zhou-yan.bat`。
- Codex：将 `zhou-yan/codex-pet/` 中的文件放入 Codex 的 `pets/zhou-yan/` 目录后重启 Codex。
