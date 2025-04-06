'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "0bd4d9bbe07b58897f9dbf37dc85ef3b",
"assets/AssetManifest.bin.json": "18bc164bd8adc0459242d64fa2ed3b4a",
"assets/AssetManifest.json": "64462b9503ca56116a33b888e285918d",
"assets/assets/ads/ad1.png": "331f4d8bca206b0f53a70c56cab52d72",
"assets/assets/ads/ad2.png": "e5ccfa63839d746891bf50d7d96c74f7",
"assets/assets/ads/ad3.png": "8a9cfb2c85032c1c650619203b50ba41",
"assets/assets/ads/ad4.jpg": "57069ff1301712818a4bcff9bc062670",
"assets/assets/images/app_logo.jpg": "4f98863257739fe19d3d34fe93eea7d6",
"assets/assets/images/default.png": "bc5f3cb173fb7c392d4de08d11ee4c32",
"assets/assets/images/farmzo_app_logo.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"assets/assets/images/farmzo_app_logo_modified.png": "2f0a98a86a0036ce87c854fb907161e3",
"assets/assets/images/farm_illustration.png": "87f665cf43595ab421bdf5c46e0c4b19",
"assets/assets/images/fruits/amla.png": "2937383bc361f8ef6fe8947ea2c0684c",
"assets/assets/images/fruits/apple.png": "99cce4f70a366f80f52ffca33911dbeb",
"assets/assets/images/fruits/bael.jpg": "0990c619a32aae41ff22c879cb5f583d",
"assets/assets/images/fruits/banana.png": "f5197d2537ca36119edc5cde348626f5",
"assets/assets/images/fruits/ber.jpg": "811e4fca4d29c76e0a40718f0c4e293e",
"assets/assets/images/fruits/blackgrapes.png": "26758bc1d6e8d1b748c573b236e2b456",
"assets/assets/images/fruits/chikoo.jpg": "1316f714033e3ca15d71ee88b2c9cc33",
"assets/assets/images/fruits/coconut.jpg": "59f59636c3cd3080493112171c46b78f",
"assets/assets/images/fruits/custardapple.jpg": "19169aa95fce3c9f64bdfd259b396208",
"assets/assets/images/fruits/fig.jpg": "728f52592af5150a4081de1f653d890b",
"assets/assets/images/fruits/greengrapes.png": "8275549df1c3ff8fbf7e06d8d129fc86",
"assets/assets/images/fruits/guava.png": "0f70314f8628ed49600f5ea0d273707f",
"assets/assets/images/fruits/jackfruit.jpg": "cd8963084243e111c8a9c27411c9de69",
"assets/assets/images/fruits/jamun.jpg": "55d8c7e979b19ebe59f43fc3af3dbd79",
"assets/assets/images/fruits/kiwi.jpg": "951bdb387c15f2bebfb683078e7667f2",
"assets/assets/images/fruits/litchi.jpg": "c568524e862e6ad9013e05d55b2c1fc4",
"assets/assets/images/fruits/mango.png": "1c2ad4d7d1c3ddc5a0dca9be4b061890",
"assets/assets/images/fruits/muskmelon.jpg": "a32bd289cc8ab0cb78a990a45b9e08c6",
"assets/assets/images/fruits/orange.png": "910da4583c92e654fd3cdf8cd5c392a0",
"assets/assets/images/fruits/papaya.jpg": "d489778ad350e24aa525890b26be41b7",
"assets/assets/images/fruits/pineapple.jpg": "7fffe362e4327b441f74ec54965242b2",
"assets/assets/images/fruits/pomegranate.jpg": "cc7e669ebceeaa66b4c139a5a28ad091",
"assets/assets/images/fruits/starfruit.jpg": "5fe2c1aa65b77f9915dd04de35e978a7",
"assets/assets/images/fruits/strawberry.jpg": "ad35f17889cc8bbc3565fa672ecc093c",
"assets/assets/images/fruits/tamarind.jpg": "9d2a74d59967d463dfbabdbe82ab291e",
"assets/assets/images/fruits/watermelon.jpg": "91c8c1dbdeeb7c80de4c595040e22746",
"assets/assets/images/leaf_pattern.jpg": "a449f9beebfa0284f0a8bd71d4b29af3",
"assets/assets/images/splash_background.jpg": "e307eb2e9bbab705e672c8ec231e9fc5",
"assets/assets/images/vegetables/amaranthus.png": "39fdc4136e22133b7fe34afd0a2b74e8",
"assets/assets/images/vegetables/beans.png": "554ec2a0334a2c15273ac616ab67f1e9",
"assets/assets/images/vegetables/beetroot.png": "5fb8e3d2a251e111412294fa8163bccc",
"assets/assets/images/vegetables/betal_leaves.png": "8c2ecf6d8bdeb0316d17b7332de6448e",
"assets/assets/images/vegetables/brinjal.png": "95ce4707f1717e64eafb7ff1d7cee0d9",
"assets/assets/images/vegetables/broccoli.png": "2a9eb7a1016761080b5ec920a9e1c6cb",
"assets/assets/images/vegetables/cabbage.png": "ce6cdad8cb338559e196c805a841580d",
"assets/assets/images/vegetables/carrot.png": "3d108034809baeaa3b47b370f4ab79f3",
"assets/assets/images/vegetables/cauliflower.png": "bb123ed48778118bfc495053d597521d",
"assets/assets/images/vegetables/cluster_beans.png": "fcd7f40c4b62da07d7cb87feb17b3935",
"assets/assets/images/vegetables/green_chilli.png": "bf8aa3878fd83c7144c7347e564d1dbc",
"assets/assets/images/vegetables/onion.png": "a0e1248dbb8ee157757c729b0f05909b",
"assets/assets/images/vegetables/potato.png": "507860a655d1b0dfb9f321c290d88673",
"assets/assets/images/vegetables/pumpkin.png": "8f71c550b1db54cf6d7b4fd1b68eb250",
"assets/assets/images/vegetables/spinach.png": "e69067a6719700f60b9a2d169cc5c218",
"assets/assets/images/vegetables/tomato.png": "9b588057796d54f4fe2c33362f2f9c3a",
"assets/FontManifest.json": "7c02eb44339caebe8ae27d0eb3b72be2",
"assets/fonts/MaterialIcons-Regular.otf": "ef432d9028d4d3d46974d6e08d032bd0",
"assets/NOTICES": "7779a00cee89d5c1bfbef75ec066d15c",
"assets/packages/flutter_iconly/fonts/IconlyBroken.ttf": "541df649654f074a25833daa64e246f3",
"assets/packages/flutter_iconly/fonts/IconlyLight.ttf": "25d014c0a013024ffb898071af3bff6c",
"assets/packages/flutter_iconly/fonts/iconly_bold.ttf": "20ae062785ef7ebe5d2eaaf4ddbb8e3a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "c863781d396686215d6c65d11489c7ae",
"icons/Icon-192.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"icons/Icon-512.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"icons/Icon-maskable-192.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"icons/Icon-maskable-512.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"index.html": "501fcf4015f5d400280bae15de535021",
"/": "501fcf4015f5d400280bae15de535021",
"main.dart.js": "f091f6d37cb37ab4ca37e270add06161",
"manifest.json": "7ddc7fea750211b5104d5a16cd175967",
"version.json": "5f483caffe235303aea0cc4b2e2465ef"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
