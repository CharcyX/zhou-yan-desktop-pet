周延独立桌宠 Windows 版

启动：双击 start-zhou-yan.bat。

要求：Windows 10/11，Python 3（安装时勾选 Add Python to PATH）。本版本使用 Python 自带 Tk，不需要额外 pip 包。

窗口使用 Windows Tk 的颜色键透明功能，并使用 Windows 专用二值 alpha 图集，避免 Tk 将半透明边缘和颜色键混合后产生紫色描边。

操作：
- 左键拖动：移动宠物，并触发向左/向右跑。
- 启动时自动放在 Windows 工作区底部，紧贴任务栏上沿，不会压到任务栏。
- 桌宠显示按 1.5 倍高 DPI 比例渲染，并将脚底对齐到工作区底边。
- 红线悬停区内持续循环说唱；蓝线到红线之间的 60 px 环形区域按鼠标位置播放 16 方向注视；蓝线外不触发注视。
- 鼠标离开悬停区后回到 idle。
- idle 先完整循环 4 次，再按 jumping → review → running → failed 的固定顺序播放；每个动作完整循环 2 次，然后回到 idle。固定序列中的 running 使用低头思考动作，不移动窗口。
- 左右拖拽累计超过 7 秒后播放 failed。
- 右键宠物或按 Esc 退出。

singing/说唱使用第 5 行唱歌素材，waiting 使用第 7 行等待素材，触发时序独立。
