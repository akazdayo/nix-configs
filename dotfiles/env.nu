# PATHの追加 (リストとして扱います)
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.bun/bin")

# GPUドライバのユーザー空間ライブラリを優先的に見せる
let gpu_lib_dir = "/run/opengl-driver/lib"
$env.LD_LIBRARY_PATH = if ("LD_LIBRARY_PATH" in $env) and (($env.LD_LIBRARY_PATH | into string | str trim) != "") {
  $"($gpu_lib_dir):($env.LD_LIBRARY_PATH)"
} else {
  $gpu_lib_dir
}
$env.NIX_LD_LIBRARY_PATH = if ("NIX_LD_LIBRARY_PATH" in $env) and (($env.NIX_LD_LIBRARY_PATH | into string | str trim) != "") {
  $"($gpu_lib_dir):($env.NIX_LD_LIBRARY_PATH)"
} else {
  $gpu_lib_dir
}

# 証明書関連の環境変数
$env.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
$env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
$env.TERM = "xterm-256color"
$env.EDITOR = "nvim"
