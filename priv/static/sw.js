// Caches the static app shell (CSS/JS/images/icons) so the installed PWA
// opens instantly. Deliberately does NOT touch page navigations or /live —
// gameplay runs over a live LiveView socket and needs a real connection;
// this service worker only makes the shell load fast, not offline-playable.
const CACHE_NAME = "be-vui-hoc-shell-v1";

const PRECACHE_URLS = [
  "/manifest.json",
  "/favicon.ico",
  "/assets/css/app.css",
  "/assets/js/app.js",
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

  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;

      return fetch(request).then((response) => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, copy));
        }
        return response;
      });
    }),
  );
});
