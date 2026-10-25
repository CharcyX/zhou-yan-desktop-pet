# Zhou Yan Desktop Pet

周延独立桌宠资产，提供 Codex v2、macOS Universal 与 Windows 版本。

## 交互

独立版的状态机和 GAI 桌宠一致：

- 待机完整循环 6 次后，按说话 → 等待 → 失败顺序播放，每个动作完整循环 3 次后回到待机。
- 鼠标悬停时循环播放 P1 说话动作；每第 3 次独立悬停，在悬停动作结束后追加一次失败反应。
- 鼠标位于角色外、距离不超过 60 px 时播放对应的 16 向注视；超过 60 px 返回待机。
- 左键拖动按水平移动方向播放跑步；累计拖动超过 7 秒后，在拖动结束时播放一次失败反应。
- 窗口启动在屏幕右下角、Dock/任务栏上方；右键退出，Windows 也可按 Esc 退出。

Windows 使用独立纯色键 RGB 图集，将 alpha 阈值化为硬边掩模，避免半透明像素与洋红背景混色产生紫边。macOS 和 Codex 保留透明 RGBA 图集。

## 目录

- `zhou-yan/codex-pet/`：Codex v2 图集。
- `zhou-yan/macOS/`：Universal App、源码、构建脚本和 RGBA 图集。
- `zhou-yan/Windows/`：Python 3 + Tk 桌宠、纯色键图集和启动脚本。
- `releases/`：macOS 与 Windows 压缩包。

Windows 需要安装 Python 3；只使用 Python 自带 Tk，不需要 pip 包。
