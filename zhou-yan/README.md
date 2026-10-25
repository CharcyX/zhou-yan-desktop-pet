# 粥盐 Desktop Pet

粥盐 的 macOS 与 Windows 桌宠，交互时序沿用 GAI 桌宠逻辑，动作素材按角色分别映射。

## 交互

- 待机完整循环 6 次后，按唱歌/说话 → 等待 → 失败顺序播放；每个动作循环 3 次后回到待机。
- 鼠标进入角色区域后持续播放P1 说话动作；每第 3 次独立悬停，在悬停动作结束后追加一次角色的负面反应。
- 鼠标在角色外、距离不超过 60 px 时，按方向播放 16 向注视；进入 60 px 外圈之外回到待机。
- 左键拖动角色时按水平移动方向播放跑步；累计拖动超过 7 秒后，在拖动结束时追加一次角色负面反应。
- 窗口初始靠屏幕右下角，停在 Dock/任务栏上方；右键退出，Windows 也可按 Esc 退出。

## 下载

- macOS：`releases/zhou-yan-desktop-pet-macos.zip`，内含 arm64 与 x86_64 Universal App。
- Windows：`releases/zhou-yan-desktop-pet-windows.zip`，Windows 10/11，需安装 Python 3；只用 Python 自带 Tk，不需要 pip 包。
- Codex：`codex-pet/` 为 v2 资产（8×11，1536×2288）。

## Windows 透明处理

Windows 使用单独的 RGB 色键图集：透明像素写成纯色 `#D12AFF`，源 alpha 以 128 阈值转为硬边蒙版，不把半透明像素与洋红背景混合。Tk 的 `-transparentcolor` 只移除该纯色，因此边缘不会出现洋红色描边。macOS 和 Codex 继续使用带 alpha 的原始 RGBA 图集。

`Windows/spritesheet.png` 已由原始 RGBA 图集生成；根目录 `tools/build_windows_keyed_atlas.py` 可重复生成。
