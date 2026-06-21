{ pkgs, ... }:
{
  programs.nixvim = {
    # 基本設定
    opts = {
      number = true;
      relativenumber = true;

      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;

      ignorecase = true;
      smartcase = true;

      clipboard = "unnamedplus";

      shell = "${pkgs.nushell}/bin/nu";

      termguicolors = true;

      wrap = false;

      # 日本語設定
      encoding = "utf-8";
      fileencoding = "utf-8";
      fileencodings = "utf-8,sjis,euc-jp,iso-2022-jp";

      # 全角スペースを可視化
      list = true;
      listchars = "tab:»-,trail:-,extends:»,precedes:«,nbsp:%";
    };

    # グローバル設定
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
  };
}
