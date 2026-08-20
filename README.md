# LidKeep

合盖也不休眠 —— macOS 菜单栏一键开关（Apple Silicon / Intel 通用）。

> Fork 自 [machinefriendly/awaketoggle](https://github.com/machinefriendly/awaketoggle)，补丁：切换时优先走 `sudo -n` 免密执行，配合 [/etc/sudoers.d 免密规则](#免密原理)，点击菜单栏图标**不再弹出密码框**。

## 功能

- 左键点击菜单栏图标：即时切换「合盖不休眠」开关
- 右键点击：打开菜单（含当前状态 + 退出）
- 图标状态：合盖图标 = 已开启；翻开图标 = 正常休眠
- 中文 / English / Français 界面

## 安装

```bash
./build.sh          # 需要 Xcode Command Line Tools（会生成 LidKeep.app）
cp -R LidKeep.app /Applications/
open /Applications/LidKeep.app
```

### 免密原理

应用每次切换都执行 `sudo /usr/bin/pmset -a disablesleep 1|0`。
只需一次性配置（安装时输一次密码）：

```bash
sudo tee /etc/sudoers.d/awake-toggle >/dev/null <<SUDOEOF
%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset -a disablesleep 0
SUDOEOF
sudo chmod 440 /etc/sudoers.d/awake-toggle
sudo visudo -c
```

⚠️ 免密范围极窄：只有上面两条精确命令。其余 sudo 操作仍然需要密码。
若删除该规则，应用会自动回退到系统授权弹窗（原版行为）。

## 使用

- 开启后：合盖（MacBook 仅插电、不接外接屏时）不再休眠，音乐/任务继续运行
- ⚠️ 注意：运行中的合盖机器散热差、耗电快。**合盖塞进包里前务必先点图标关闭**。

## 验证状态

```bash
pmset -g | grep SleepDisabled   # 1 = 已禁用合盖休眠，0 = 正常休眠
```

## 从源码构建

仅需 Xcode Command Line Tools（`xcode-select --install`）：

```bash
./build.sh   # 输出通用二进制（arm64 + x86_64），ad-hoc 签名
```

## 许可

MIT / BSD-1-Clause（继承上游 AwakeToggle 的双许可，保留原作者署名）。