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

**Chosen setup: Option B, StreamElements.** Steps below are the actual
walkthrough to follow.

## Option B — StreamElements (recommended for most people)

Free, browser-based (no desktop app required), widely used. Gives you a
viewer counter, follower goal bar, and an alert box (pop-up + sound when
someone follows/subs/donates) as ready-made overlay URLs you paste into
OBS Browser Sources — no OBS plugin needed.

Setup — this is a manual, one-time walkthrough you do yourself: signing in
with your own Twitch account is a login step only you should perform
(don't hand credentials to anything else, including an assistant).

1. Go to **streamelements.com** → click **Sign in / Get Started** → choose
   **Sign in with Twitch**. Approve the OAuth prompt (it asks for read
   access to your channel/follows/stream status — you don't need to grant
   chat/moderation scopes for this use case).
2. In the dashboard sidebar, go to **My Overlays** (sometimes shown as
   **Overlays**) → **+ Add Overlay** → **Create empty overlay** (or start
   from a template if you want pre-made styling).
3. Inside the overlay editor, use the widget panel to drag in:
   - **Viewer Count** (may be listed as "Follower/Viewer Count" or under
     "Stream Stats") — shows live viewer count, and follower count if you
     add that field too.
   - **Alertbox** — pop-up + sound whenever someone follows (also covers
     subs/raids/donations if you want them later). This is your "who's
     following" live activity.
   - Optional: **Follower Goal** bar, **Recent Events** widget for a
     scrolling follow/sub log.
   Resize/position each widget within the overlay canvas as you'd like it
   to appear on stream, then **Save**.
4. Click **Overlay settings** (or the "..." menu) → copy the overlay's
   unique **Browser Source URL**.
5. In OBS: add a **Browser Source** to your scene → paste that URL → set
   width/height to match your OBS canvas (e.g. 1920x1080) → check **"Shutdown
   source when not visible"** off if you want alerts to keep working even
   when the scene isn't focused momentarily. Background renders transparent
   automatically.
6. In the StreamElements dashboard, use the **Alertbox → Test Alert** button
   to fire a test follow alert and confirm it shows up correctly on the OBS
   preview before going live.

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
