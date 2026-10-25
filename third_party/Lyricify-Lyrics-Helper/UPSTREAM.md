# Lyricify Lyrics Helper

Upstream: https://github.com/WXRIW/Lyricify-Lyrics-Helper

Pinned commit: `3fc579b029c24a1f54ebb2fd002ee3624c85c7e7` (library version 0.2.1).

The `Lyricify.Lyrics.Helper/` source, documentation, README and LICENSE are preserved.
Local modifications: the project omits the unused proprietary `CHTCHSConv` package;
`ChineseHelper.S2T/T2S` use the existing upstream dictionary converter instead.
The NetEase provider, LRC parser and lyrics models are unchanged. The demo project and its example media/lyrics are excluded.

Desktop Studio uses `Providers.Web.Netease.Api.GetLyric()` and `Parsers.LrcParser`.
The adapter, local cache, Rainmeter transport and UI live outside this directory.
Upstream code remains Apache-2.0, copyright its respective contributors.
