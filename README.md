# NixOS Configuration

モジュール化されたNixOS設定ファイルです。

## ディレクトリ構造

```
.
├── configuration.nix          # メインエントリーポイント（hosts/nixosをインポート）
├── flake.nix                  # Flake設定
├── hardware-configuration.nix # ハードウェア自動検出設定
├── dotfiles/                  # シェル設定ファイル
├── home/                      # Home Manager設定
│   ├── default.nix           # Home Managerのメインファイル
│   └── programs/             # プログラム別設定
│       ├── git.nix           # Git設定
│       ├── gnome.nix         # GNOME/dconf設定
│       ├── packages.nix      # ユーザーパッケージ
│       └── shell.nix         # シェル設定
├── hosts/                     # ホスト固有の設定
│   └── nixos/                # ホスト "nixos"
│       └── default.nix       # このホストのメイン設定
└── modules/                   # 機能別モジュール
    ├── audio/                # オーディオ設定（PipeWire）
    ├── boot/                 # ブート設定
    ├── desktop/              # デスクトップ環境（X11/GNOME）
    ├── gaming/               # ゲーム関連（Steam）
    ├── hardware/             # ハードウェア固有設定（NVIDIA）
    ├── locale/               # ロケール/フォント/入力メソッド
    ├── networking/           # ネットワーク設定
    ├── users/                # ユーザー設定
    └── vr/                   # VR関連（WiVRn）
```

## 使い方

### 設定を適用する

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### 設定をテストする（再起動せずに適用）

```bash
sudo nixos-rebuild test --flake .#nixos
```

### ビルドのみ（適用しない）

```bash
nixos-rebuild dry-build --flake .#nixos
```

### Flake設定をチェック

```bash
nix flake check
```

## 新しいモジュールを追加する

1. `modules/` に新しいディレクトリとファイルを作成
2. `hosts/nixos/default.nix` の `imports` に追加

例：
```nix
# modules/新機能/default.nix
{pkgs, ...}: {
  # 設定をここに記述
}
```

```nix
# hosts/nixos/default.nix
{
  imports = [
    # ...
    ../../modules/新機能
  ];
}
```

## Home Manager設定を追加する

1. `home/programs/` に新しいファイルを作成
2. `home/default.nix` の `imports` に追加

## バックアップファイル

以下のファイルは元の設定のバックアップです：
- `configuration.nix.backup` - 元のconfiguration.nix
- `home.nix.backup` - 元のhome.nix

設定が正常に動作することを確認したら削除できます。
