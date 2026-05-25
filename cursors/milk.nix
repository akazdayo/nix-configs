{ pkgs, lib, ... }:

let
  # --- 1. 設定: マッピング定義 ---
  # 日本語のファイル名の一部 (key) と、X11のカーソル名リスト (value)
  # リストの先頭が実ファイル名、2番目以降がシンボリックリンクになります
  cursorMap = {
    "通常" = [
      "left_ptr"
      "default"
      "arrow"
    ];
    "リンク" = [
      "hand2"
      "pointer"
      "hand"
      "link"
    ];
    "テキスト" = [
      "xterm"
      "text"
    ];
    "待ち" = [
      "watch"
      "wait"
    ];
    "移動" = [
      "fleur"
      "move"
    ];
    "左右" = [
      "sb_h_double_arrow"
      "h_double_arrow"
      "size_hor"
    ];
    "上下" = [
      "sb_v_double_arrow"
      "v_double_arrow"
      "size_ver"
    ];
    "斜めに拡大・縮小1" = [
      "bd_double_arrow"
      "size_fdiag"
    ];
    "斜めに拡大・縮小2" = [
      "fd_double_arrow"
      "size_bdiag"
    ];
    "ヘルプ" = [
      "question_arrow"
      "help"
    ];
    "利用不可" = [
      "crossed_circle"
      "not-allowed"
    ];
    "ペン" = [ "pencil" ];
  };

  themeName = "MyCustomCursor";

in
pkgs.stdenv.mkDerivation {
  name = "milk-cursor-theme";

  # --- 2. ソースの取得 (requireFile) ---
  src = pkgs.requireFile {
    name = "Milk_Cursor.zip";
    url = "https://booth.pm/ja/items/4046750";
    sha256 = "f4b34576fd04498dda6554b0c5aa5d9551d1fff5a8dd185cafdfedf250333563";
    message = "BOOTHからダウンロードしたzipファイルを 'nix-store --add-fixed sha256 <file>' で登録してください。";
  };

  # ビルドに必要なツール
  nativeBuildInputs = with pkgs; [
    unar
    win2xcur
  ];

  # ソースを展開しないようにする（手動でunzipするため）
  unpackPhase = "true";

  # --- 3. インストールフェーズ (変換スクリプトの本体) ---
  installPhase = ''
    # 出力先ディレクトリの作成
    cursorDir=$out/share/icons/${themeName}/cursors
    mkdir -p $cursorDir

    # 作業用の一時ディレクトリを作成して展開
    mkdir -p build_tmp
    unar $src
    mv ./"Milk Cursor"/Milk1/ ./build_tmp/
    cd build_tmp

    # NixのMap定義をbashのロジックに展開して実行
    # findコマンドを使ってファイル名の一部(key)に一致するファイルを探します
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        key: names:
        let
          primary = builtins.head names;
          aliases = builtins.tail names;
        in
        ''
          targetFile=$(find . -maxdepth 2 -name "*${key}*.ani" -o -name "*${key}*.cur" | head -n 1)

          if [ -n "$targetFile" ]; then
            win2xcur "$targetFile" -o "$cursorDir/" >/dev/null
            originalBaseName=$(basename "$targetFile")
            generatedFile="$cursorDir/''${originalBaseName%.*}"

            if [ -f "$generatedFile" ]; then
               mv "$generatedFile" "$cursorDir/${primary}"

               # シンボリックリンクの作成 (エイリアス)
               ${lib.concatMapStringsSep "\n" (alias: ''
                 ln -sf "${primary}" "$cursorDir/${alias}"
               '') aliases}
            else
               echo "    [Error] Output not found for $targetFile"
            fi
          else
            echo "    [Skip] Source file for '${key}' not found."
          fi
        ''
      ) cursorMap
    )}

    # --- index.theme の生成 ---
    echo "[Icon Theme]
    Name=${themeName}
    Comment=Converted from Windows Cursor via Nix
    Inherits=core
    " > $out/share/icons/${themeName}/index.theme
  '';
}
