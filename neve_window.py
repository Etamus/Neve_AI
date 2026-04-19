"""
Neve AI — Abre a interface em janela de app isolada usando o navegador padrão
do sistema em modo --app (Chrome, Brave, Edge ou qualquer Chromium).
Sem dependências externas além da stdlib do Python.
"""

import os
import re
import subprocess
import webbrowser
import winreg

_BASE_DIR = os.path.dirname(os.path.abspath(__file__))
_PROFILE   = os.path.join(_BASE_DIR, "logs", "browser-app")
_URL       = "http://localhost:8080"

# ProgIds de navegadores NÃO-Chromium — não suportam --app isolado
_NON_CHROMIUM = {"firefoxurl", "firefoxhtml", "operahtml", "iexplore", "msedgehtm"}


def _chromium_exe_from_progid(prog_id: str) -> str | None:
    """
    Lê HKCR\\<ProgId>\\shell\\open\\command e extrai o caminho do .exe.
    Retorna None se o ProgId não for de um navegador Chromium.
    """
    if prog_id.lower() in _NON_CHROMIUM:
        return None
    try:
        key = winreg.OpenKey(winreg.HKEY_CLASSES_ROOT,
                             rf"{prog_id}\shell\open\command")
        cmd, _ = winreg.QueryValueEx(key, "")
        winreg.CloseKey(key)
        # Extrai caminho entre aspas: "C:\path\browser.exe" ...
        m = re.match(r'"([^"]+\.exe)"', cmd, re.IGNORECASE)
        if m:
            exe = m.group(1)
            return exe if os.path.exists(exe) else None
    except OSError:
        pass
    return None


def _find_chromium_browser() -> str | None:
    """Detecta o navegador padrão do sistema e retorna o exe se for Chromium."""
    try:
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\Shell\Associations"
            r"\UrlAssociations\http\UserChoice",
        )
        prog_id, _ = winreg.QueryValueEx(key, "ProgId")
        winreg.CloseKey(key)
        return _chromium_exe_from_progid(prog_id)
    except OSError:
        return None


def main():
    browser = _find_chromium_browser()
    if browser:
        os.makedirs(_PROFILE, exist_ok=True)
        subprocess.Popen([
            browser,
            f"--app={_URL}",
            "--window-size=1280,820",
            "--no-first-run",
            "--no-default-browser-check",
            "--disable-extensions",
            f"--user-data-dir={_PROFILE}",
        ])
    else:
        # Navegador não-Chromium ou não detectado — abre normalmente
        webbrowser.open(_URL)


if __name__ == "__main__":
    main()


