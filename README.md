# Docker ABiS 2026

- ABiS脳MRIチュートリアルの環境をDockerコンテナで構築するプロジェクトです。
- noVNC版を開発します。

## 事前準備

- 共有するためのディレクトリを作成し、そこにFreeSurferのライセンス、license.txt を保存してください

## コンテナの起動
- ターミナル/Powershellでそのディレクトリに移動します

```bash
cd 共有するディレクトリのパス
```

- そのうえで、以下のコマンドでコンテナを起動します
から以下を実行してください

```bash
docker run \
  --shm-size=4g \
  --privileged \
  --platform linux/amd64 \
  --name abis \
  -d -p 6080:6080 \
  -v .:/home/brain/share \
  kytk/abis-novnc:latest
```

## Lin4Neuroへのアクセス

Webブラウザで `http://localhost:6080/vnc.html` にアクセスすると、Lin4Neuroデスクトップ環境を使用できます。

## カスタム解像度

- コンテナ起動時にカスタム解像度を指定できます：
- 指定しない場合、デフォルトの解像度は1600x900x24です。

```bash
docker run \
  --shm-size=4g \
  --privileged \
  --platform linux/amd64 \
  --name abis \
  -e RESOLUTION=1600x900x24 \
  -d -p 6080:6080 \
  -v .:/home/brain/share \
  kytk/abis-novnc:latest
```



## 注意

このDockerイメージは研究および教育目的で提供されています。含まれるソフトウェアパッケージのライセンス条項を遵守してご使用ください。
