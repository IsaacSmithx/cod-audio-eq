# Showing Twitch viewer count / followers in OBS

Twitch does not ship an official "drop this browser source in OBS" widget
for viewer count or live follower activity — those overlays come from a
third-party service (StreamElements, Streamlabs) or a small public API you
point a Browser Source at. Pick based on how much you want to install vs.
how much you want to connect your Twitch account to.

**Any option below that pulls live data tied to your channel needs your
Twitch account connected to that service (OAuth), and a couple of them
mean creating an account on that service. Don't connect/create anything
until you've decided which route you want — this doc is written so you can
read all options first, then tell me/do the one you pick.**

## Option A — No account, no OAuth: simple text overlay via a public API

Uses a free public endpoint (e.g. `decapi.me`) that returns plain text for
things like viewer count or follower count. No Twitch login, no third-party
account, minimal features (no follower alert pop-ups, just numbers).

1. In OBS, add a **Browser Source** to your scene.
2. Set the URL to something like:
   - Viewer count: `https://decapi.me/twitch/viewercount/<your_channel>`
   - Follower count: `https://decapi.me/twitch/followcount/<your_channel>`
3. Set width/height small (e.g. 300x60), and style with a Text/CSS wrapper
   page if you want a font/color instead of raw plain text.
4. These endpoints don't auto-push updates, so set the Browser Source to
   refresh periodically: right-click the source → Properties → check
   "Refresh browser when scene becomes active", or use a small local HTML
   wrapper with a `<meta http-equiv="refresh">` / JS `setInterval` reload
   every 30-60s.

Good for: minimal setup, privacy-conscious, don't want a dashboard account.
Limits: no follower alert animations, no unified stream-stats dashboard,
you maintain the wrapper page yourself if you want styling/auto-refresh.

## Option B — StreamElements (recommended for most people)

Free, browser-based (no desktop app required), widely used. Gives you a
viewer counter, follower goal bar, and an alert box (pop-up + sound when
someone follows/subs/donates) as ready-made overlay URLs you paste into
OBS Browser Sources — no OBS plugin needed.

Setup (once you say go-ahead, since step 1 connects your Twitch account):

1. Go to streamelements.com and sign in **with Twitch** (this is the
   account-connect step — it requests read access to your channel's
   follows/stream status, not posting/moderation rights unless you grant
   them).
2. In the StreamElements dashboard: **Overlays** → create/edit an overlay →
   add a **Viewer Count** widget and/or **Follower Goal** widget and/or
   **Alertbox** widget.
3. Each overlay has a unique "Overlay URL" — copy it.
4. In OBS: Add **Browser Source** → paste that URL → set canvas-matching
   width/height → OBS renders it live, transparent background included.
5. Test alerts from the StreamElements dashboard's "Test Alert" button
   before going live.

## Option C — Streamlabs

Same idea as StreamElements — sign in with Twitch, build overlay widgets
(viewer count, follower/sub alerts, goal bars), copy Browser Source URLs
into OBS. Also offers "Streamlabs Desktop," a full OBS-alternative app with
built-in widgets if you'd rather not run vanilla OBS + Browser Sources at
all (bigger switch — probably not worth it for a working OBS setup already
built around COD scenes/filters).

## Recommendation

For "see viewer count and follower/activity in OBS" with minimal fuss:
**StreamElements Browser Source widgets (Option B)** is the common choice —
free, no desktop app swap, alerts + viewer count + follower goal in a few
Browser Sources. Option A is the fallback if you'd rather not connect a
third-party account to Twitch at all.
