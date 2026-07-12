#!/usr/bin/env python3
"""Avvia waybar dietro un proxy del socket comandi di Hyprland.

Perché: la config di Hyprland è in Lua (hyprland.lua), quindi l'IPC interpreta
i comandi come Lua. Il modulo nativo hyprland/workspaces manda la sintassi
legacy "dispatch workspace N", che in Lua è un errore:

    dispatch workspace 3  ->  return hl.dispatch(workspace 3)  -> syntax error

così il click sui workspace non cambia workspace.

Soluzione: waybar parla con un socket proxy (stesso schema di Hyprland ma sotto
una signature fittizia "waybar-proxy"). Il proxy riscrive SOLO
"dispatch workspace N" nella forma Lua e inoltra tutto il resto invariato. Il
socket eventi (.socket2.sock, sola lettura) è un symlink a quello vero.

Un proxy asyncio persistente: nessun fork per connessione e la richiesta viene
letta appena arriva (una recv), senza attese. Fondamentale perché waybar
ri-interroga lo stato via socket comandi a ogni cambio workspace: un handler
lento renderebbe la barra pigra ad aggiornarsi.
"""
import asyncio
import os

PROXY_SIG = "waybar-proxy"
PREFIX = b"dispatch workspace "

xdg = os.environ["XDG_RUNTIME_DIR"]
real_sig = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
real_dir = f"{xdg}/hypr/{real_sig}"
real_sock = f"{real_dir}/.socket.sock"
proxy_dir = f"{xdg}/hypr/{PROXY_SIG}"
proxy_sock = f"{proxy_dir}/.socket.sock"


def rewrite(req: bytes) -> bytes:
    """dispatch workspace N -> dispatch hl.dsp.focus({workspace=N}); resto invariato."""
    if not req.startswith(PREFIX):
        return req
    arg = req[len(PREFIX):].decode(errors="replace").strip()
    if arg.isdigit():
        return f"dispatch hl.dsp.focus({{workspace={arg}}})".encode()
    # workspace relativi/nominati (e+1, name:foo, ...): stringa Lua
    return f'dispatch hl.dsp.focus({{workspace="{arg}"}})'.encode()


async def handle(reader, writer):
    try:
        # Socket comandi = una richiesta per connessione; read() torna appena
        # i byte arrivano (non aspetta EOF), quindi zero latenza aggiunta.
        req = await reader.read(65536)
        if not req:
            return
        rr, rw = await asyncio.open_unix_connection(real_sock)
        rw.write(rewrite(req))
        await rw.drain()
        rw.write_eof()
        writer.write(await rr.read())
        await writer.drain()
        rw.close()
    except (OSError, asyncio.IncompleteReadError):
        pass
    finally:
        try:
            writer.close()
        except OSError:
            pass


async def main():
    os.makedirs(proxy_dir, exist_ok=True)
    link = f"{proxy_dir}/.socket2.sock"
    for path in (link, proxy_sock):
        try:
            os.remove(path)
        except FileNotFoundError:
            pass
    os.symlink(f"{real_dir}/.socket2.sock", link)

    server = await asyncio.start_unix_server(handle, path=proxy_sock)
    env = dict(os.environ, HYPRLAND_INSTANCE_SIGNATURE=PROXY_SIG)
    waybar = await asyncio.create_subprocess_exec("waybar", env=env)
    async with server:
        await waybar.wait()

    try:
        os.remove(proxy_sock)
    except FileNotFoundError:
        pass


if __name__ == "__main__":
    asyncio.run(main())
