// Caches the static app shell (CSS/JS/images/icons) so the installed PWA
// opens instantly. Deliberately does NOT touch page navigations or /live —
// gameplay runs over a live LiveView socket and needs a real connection;
// this service worker only makes the shell load fast, not offline-playable.
const CACHE_NAME = "be-vui-hoc-shell-v6";

const PRECACHE_URLS = [
  "/manifest.json",
  "/favicon.ico",
  "/assets/css/app.css",
  "/assets/js/app.js",
  "/images/assets/horse_red.webp",
  "/images/assets/horse_green.webp",
  "/images/assets/horse_yellow.webp",
  "/images/assets/horse_blue.webp",
  "/images/assets/die_1.webp",
  "/images/assets/die_2.webp",
  "/images/assets/die_3.webp",
  "/images/assets/die_4.webp",
  "/images/assets/die_5.webp",
  "/images/assets/die_6.webp",
  "/images/assets/trophy_gold.webp",
  // Landing page: hero illustration + the generated toy icon family.
  "/images/landing/hero_family.webp",
  "/images/ui/logo.webp",
  "/images/ui/dice.webp",
  "/images/ui/horse.webp",
  "/images/ui/trophy.webp",
  "/images/ui/device.webp",
  "/images/ui/family.webp",
  "/images/ui/tap.webp",
  "/images/ui/shield.webp",
  "/images/ui/offline.webp",
  "/images/ui/brain.webp",
  "/images/ui/players.webp",
  "/images/ui/age.webp",
  "/images/ui/timer.webp",
  "/images/ui/together.webp",
  "/images/ui/check.webp",
  "/images/ui/party.webp",
  "/images/ui/piece_chess.webp",
  "/images/ui/piece_go.webp",
  "/images/ui/piece_xiangqi.webp",
  // Game screen controls.
  "/images/ui/settings.webp",
  "/images/ui/restart.webp",
  "/images/ui/home.webp",
  "/images/ui/exit.webp",
  "/images/ui/undo.webp",
  "/images/ui/phone.webp",
];

self.addEventListener("install", (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHE_URLS).catch(() => {})),
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET") return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  // Never intercept the LiveView websocket upgrade or its long-poll fallback.
  if (url.pathname.startsWith("/live")) return;

  const isStaticAsset =
    url.pathname.startsWith("/assets/") ||
    url.pathname.startsWith("/images/") ||
    url.pathname === "/favicon.ico" ||
    url.pathname === "/manifest.json";

  if (!isStaticAsset) return;

  // Stale-while-revalidate: serve the cached copy immediately if there is
  // one (fast repeat loads), but always refetch in the background and
  // update the cache — so an asset that changed on a new deploy is never
  // stuck serving the old copy forever, just for one extra load at worst.
  event.respondWith(
    caches.open(CACHE_NAME).then((cache) =>
      cache.match(request).then((cached) => {
        const network = fetch(request)
          .then((response) => {
            if (response.ok) cache.put(request, response.clone());
            return response;
          })
          .catch(() => cached);

        return cached || network;
      }),
    ),
  );
});
