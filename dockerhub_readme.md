# kytk/abis-2026 - Neuroimaging Analysis Integrated Environment for ABiS tutorial

[English](#english) | [日本語](#japanese)

---

## English

### Overview
`kytk/abis-2026` is a comprehensive Docker container for neuroimaging analysis, providing a complete desktop environment with pre-installed neuroimaging software packages. The container runs an XFCE4 desktop accessible via web browser through noVNC.

### Features
- **Complete Desktop Environment**: XFCE4 desktop with web browser access
- **Pre-installed Neuroimaging Software**:
  - FreeSurfer 8.1.0
  - FSL 6.0.7.18
  - ANTs (Advanced Normalization Tools)
  - SPM25 Standalone
  - CONN v22v2407 Standalone
  - MRtrix3
  - dcm2niix
  - MRIcroGL
  - Mango
  - AlizaMS
- **Development Tools**: Python 3, Jupyter Notebook, Octave, Git
- **Multi-language Support**: English and Japanese fonts/locales

### Quick Start

#### Prerequisites
- Docker installed on your system
- FreeSurfer license file (`license.txt`)

#### Basic Usage (GUI Mode)
```bash
# Place your FreeSurfer license.txt in the current directory
docker run -d \
  -p 6080:6080 \
  -v .:/home/brain/share \
  --name abis-2026 \
  kytk/abis-2026
```

#### Interactive Shell Mode
```bash
docker run -it \
  -v .:/home/brain/share \
  -e MODE=bash \
  --name abis-2026 \
  kytk/abis-2026
```

#### Access the Desktop
1. Open your web browser
2. Navigate to `http://localhost:6080`
3. Enter password: `lin4neuro`

### Environment Modes

#### GUI Mode (Default)
- Starts XFCE4 desktop environment
- Accessible via web browser at `http://localhost:6080`
- Password: `lin4neuro`

#### Bash Mode
- Provides interactive command-line access
- Use `-e MODE=bash` flag
- All neuroimaging tools available in PATH

### Volume Mounts

#### Required: FreeSurfer License
```bash
-v .:/home/brain/share
```
**Important**: Your FreeSurfer `license.txt` must be in the mounted directory.

#### Optional: Data Directory
```bash
-v /path/to/your/data:/home/brain/data
```

### Port Mapping
- Port `6080`: noVNC web interface

### Default User
- Username: `brain`
- Password: `lin4neuro`
- Home directory: `/home/brain`

### Software Paths and Aliases
- **FreeSurfer**: `/usr/local/freesurfer/8.1.0` (automatically configured)
- **FSL**: `/usr/local/fsl` (FSLDIR set)
- **SPM25**: `spm25` command alias
- **CONN**: `conn` command alias
- **ANTs**: Available in PATH
- **MRtrix3**: Available in PATH

### Example Commands
```bash
# Run with data mount
docker run -d \
  -p 6080:6080 \
  -v .:/home/brain/share \
  -v /path/to/neuroimaging/data:/home/brain/data \
  --name abis-2026 \
  kytk/abis-2026

# Interactive session
docker run -it \
  -v .:/home/brain/share \
  -e MODE=bash \
  kytk/abis-2026 \
  /bin/bash

# With memory limit
docker run -d \
  -p 6080:6080 \
  -v .:/home/brain/share \
  -m 8g \
  --name abis-2026 \
  kytk/abis-2026
```

### Troubleshooting
- If GUI doesn't load, wait 30 seconds for all services to start
- Check container logs: `docker logs abis-2026`
- Restart container: `docker restart abis-2026`

---

## Japanese

### 概要
`kytk/abis-2026` は、神経画像解析のための統合Dockerコンテナです。事前にインストールされた神経画像解析ソフトウェアパッケージを含む完全なデスクトップ環境を提供し、noVNCを通じてWebブラウザからXFCE4デスクトップにアクセスできます。

### 特徴
- **完全なデスクトップ環境**: WebブラウザアクセスでXFCE4デスクトップ
- **事前インストール済み神経画像解析ソフトウェア**:
  - FreeSurfer 8.1.0
  - FSL 6.0.7.18
  - ANTs (Advanced Normalization Tools)
  - SPM25 スタンドアロン版
  - CONN v22v2407 スタンドアロン版
  - MRtrix3
  - dcm2niix
  - MRIcroGL
  - Mango
  - AlizaMS
- **開発ツール**: Python 3, Jupyter Notebook, Octave, Git
- **多言語サポート**: 英語・日本語フォント/ロケール

### クイックスタート

#### 前提条件
- システムにDockerがインストールされていること
- FreeSurferライセンスファイル（`license.txt`）

#### 基本使用方法（GUIモード）
```bash
# FreeSurferのlicense.txtを現在のディレクトリに配置
docker run -d \
  -p 6080:6080 \
  -v .:/home/brain/share \
  --name abis-2026 \
  kytk/abis-2026
```

#### 対話型シェルモード
```bash
docker run -it \
  -v .:/home/brain/share \
  -e MODE=bash \
  --name abis-2026 \
  kytk/abis-2026
```

#### デスクトップへのアクセス
1. Webブラウザを開く
2. `http://localhost:6080` にアクセス
3. パスワードを入力: `lin4neuro`

### 環境モード

#### GUIモード（デフォルト）
- XFCE4デスクトップ環境を開始
- Webブラウザから `http://localhost:6080` でアクセス
- パスワード: `lin4neuro`

#### Bashモード
- 対話型コマンドラインアクセスを提供
- `-e MODE=bash` フラグを使用
- すべての神経画像解析ツールがPATHで利用可能

### ボリュームマウント

#### 必須: FreeSurferライセンス
```bash
-v .:/home/brain/share
```
**重要**: FreeSurferの `license.txt` がマウントされたディレクトリに存在する必要があります。

#### オプション: データディレクトリ
```bash
-v /path/to/your/data:/home/brain/data
```

### ポートマッピング
- ポート `6080`: noVNC Webインターフェース

### デフォルトユーザー
- ユーザー名: `brain`
- パスワード: `lin4neuro`
- ホームディレクトリ: `/home/brain`

### ソフトウェアパスとエイリアス
- **FreeSurfer**: `/usr/local/freesurfer/8.1.0` (自動設定)
- **FSL**: `/usr/local/fsl` (FSLDIR設定済み)
- **SPM25**: `spm25` コマンドエイリアス
- **CONN**: `conn` コマンドエイリアス
- **ANTs**: PATH利用可能
- **MRtrix3**: PATH利用可能

### コマンド例
```bash
# データマウントありで実行
docker run -d \
  -p 6080:6080 \
  -v .:/home/brain/share \
  -v /path/to/neuroimaging/data:/home/brain/data \
  --name abis-2026 \
  kytk/abis-2026

# 対話セッション
docker run -it \
  -v .:/home/brain/share \
  -e MODE=bash \
  kytk/abis-2026 \
  /bin/bash

# メモリ制限あり
docker run -d \
  -p 6080:6080 \
  -v .:/home/brain/share \
  -m 8g \
  --name abis-2026 \
  kytk/abis-2026
```

### トラブルシューティング
- GUIが読み込まれない場合は、すべてのサービスが開始されるまで30秒お待ちください
- コンテナログを確認: `docker logs abis-2026`
- コンテナを再起動: `docker restart abis-2026`

---

## Technical Details

### System Requirements
- RAM: 4GB minimum, 8GB+ recommended
- Disk space: ~15GB for container image
- Supported platforms: Linux (x86_64)

### Container Details
- Base image: Ubuntu 22.04 LTS
- Desktop environment: XFCE4
- VNC server: x11vnc
- Web interface: noVNC
- Default user: brain (non-root)

### License
This container includes various neuroimaging software packages, each with their own licenses. Users are responsible for ensuring compliance with all applicable licenses, particularly the FreeSurfer license agreement.

### Support
- Created by: K. Nemoto
- Issues and questions: Please refer to the documentation of individual software packages
- Container-specific issues: Contact the maintainer

### Version History
- abis-2026: Latest integrated neuroimaging analysis environment with multi-stage build optimization
