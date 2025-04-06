'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "f41191bb585c1ce8dcdea2d25fbaea8a",
".git/config": "3a780366e1ddabd645a5f4b1b5879c8a",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "a6b7129c1f1a7812d5b5f85040f8669d",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "94b370b6688f39e9e367db8e8f86b98e",
".git/logs/refs/heads/gh-pages": "94b370b6688f39e9e367db8e8f86b98e",
".git/logs/refs/remotes/origin/gh-pages": "3de35316fdd4f4d61995b18cae9a1081",
".git/objects/01/1ec18a9aa1948e461c2656a8b08e41635ef8da": "a852713e74aa0f9761a978aaf980c5d1",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/09/32ced07fd50944bb12927b1eab900b4c460525": "2cecc0aa455ba36727db7380baefe756",
".git/objects/0a/8c0367930edaeafcc8c62a21706f7f8c796fae": "663397038af6eba90e7f9432eb5e42c6",
".git/objects/0c/0beb9f7d4079e255643bde45c2b46e942d1a47": "77f8ab7f2a449d1a5bae418809e75f71",
".git/objects/11/339cb3eede85c09fc6496591256f71ce8713a6": "c5c21a9c3be27db74e97ef9ab0eaa10a",
".git/objects/16/2738fcdbd51543287f6174bed1dd71bc81b1b1": "3ea654bd9434b955a18bb2119bcc94eb",
".git/objects/19/ae11ec96a86e886a08adc79b93d048fe36f0c6": "41e49e2a801c1cad55a14cb6d6140874",
".git/objects/1a/02928fa11534c2bcb3003ca06f04babdbf99c5": "aa5bfe13f10dd849a770a9121c173b33",
".git/objects/1b/5fd4bacd00e0a8918743cd7ffe9ac16f802794": "08969ca845304fae176af14901e700a2",
".git/objects/1d/ecb6528853847755a2191e1425861bbc31bded": "b7c5bc37a52f7c89aeb2c86480f05952",
".git/objects/20/93439649c6528dbb2c7797e67fb02d607c3134": "44e7eea154ad76db9c540c9af93fb016",
".git/objects/21/6b99fe9f977f81fa3dac07437ba294756b1a06": "fd34d599e6a1fdeabd9ce6ad9e5ace48",
".git/objects/21/f93b5a32c36a5388a932a7dc42cb4fe05c538b": "32603fe1419f21151067bccec12e901c",
".git/objects/26/8bae7c6d45ce01f486510a6eb3d5956cbed5c7": "5b4d92812d00789d7d3bd8e9d9891481",
".git/objects/26/c684e068c68ac8c999e0cb408f180048fc5538": "d8bf46bc80edbae1dc4c72af74e98acd",
".git/objects/28/bae72581c9dc1ce4637d7125d5bfe0014978a7": "9aedaecad4dd1e51b188c51c3a933c35",
".git/objects/2c/d99aea4ed9de851cf92022f12ccf6086ad760e": "90577197d731cc4a72a74fb23e162ff4",
".git/objects/2d/67868dd621f4b60e7dab582c7a97f01e1e5c9d": "1694e4293d9555e0d2c4d5ccbb18c9cb",
".git/objects/33/31d9290f04df89cea3fb794306a371fcca1cd9": "e54527b2478950463abbc6b22442144e",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/36/1a7a20d8f884b29b96b564391d70fd5a01712d": "5ac24d2195faa542e14bbd00674b3c84",
".git/objects/3a/22b92aa241e1eb09fcf538bf6f218210342a6b": "0da671622ebe3b39661d91e69ba960e2",
".git/objects/3c/658a49bfcbcf57436f4fd590294d42bd863793": "9c3481fd9e656ce736c8b6be2877816e",
".git/objects/3e/360a76184566f7cbf069c6b50f02ed5eaa67e1": "f53383392ae50a6cad4399b4b224b164",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/43/205ef4f520e137cd1e1cb911c44ccd2d304dd8": "684ca3d5532f9199cafa779c346d48a5",
".git/objects/45/f139989e594de2bd19a31a34ad906924766e64": "8570c0aa12b104e0254de9b78d902b0f",
".git/objects/47/2e07d10d6f0d8a390956740fd5af18221f7d61": "3348d3e0192e8ad677343f341017065d",
".git/objects/4b/4c838eb8f9a26ca48ee0e7e077cc2ba9151031": "0018171eb9ceadf2a50afb661fe04c1b",
".git/objects/4c/fe81910f702f5eca74b2ac30582356e45a3304": "f6992224cfaefd1de22f0fb6387ae79e",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/50/6e3611d747cd83f95a31d38b413a1bade18b93": "8c376e4f3d0cc07495ec988b9319f0e4",
".git/objects/51/2028be83f13d189a9806973f65f211fcfaa29f": "763ae32a11bc47819def11d53b0113e3",
".git/objects/55/d9d76421bb663491b57e2fc53feb87e4bd5513": "5fc6655eb4c071de8b650080f7078b10",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/58/78da222f5a8fa74dcfb36535204399ddd32a02": "36c58aee79041cfdf5da5667f8ba0e8a",
".git/objects/5a/13bd5a18e506d22647433b1980295ce67bcebe": "50b077c2b68b737800ac0d99a322b746",
".git/objects/5a/6a6fc46af650a2f3f1b2e4d613de8cc15e02d8": "836bcf0eede6e607661368f00cea468b",
".git/objects/5b/aa90d5420ce3f12128797657bc5015f5442f5a": "8a71b6a850ba06a23a355f6c5832bdcb",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/61/ec275cec8fbf69a7a2e972911998a521c33324": "83dc86c4b25c427133cedb651d652be2",
".git/objects/64/5116c20530a7bd227658a3c51e004a3f0aefab": "f10b5403684ce7848d8165b3d1d5bbbe",
".git/objects/6a/cf81dc256323ecf44c81d44ed49c11a949e284": "273c9a59c603d08cfd654dda620b0e3b",
".git/objects/6d/456a74f7a8297da77d3470b8e229ad224c500a": "b76014ef3f49db336c28aa0e4542cac6",
".git/objects/6e/7d82197a30429267ddb8cd5bd16fc492fe4c7e": "a279f5fe6eb0bcc177635492f35b2b07",
".git/objects/73/c7120ce786ac749f3a4817f144890732883c81": "bd9756ccdfec46e82dfe52427a01567e",
".git/objects/73/f3dcf864f9ae6d4770dd40bdd0f363a1326435": "d266dc41b88dcc130481f92351ac90cc",
".git/objects/74/4dda169e6361ef78d1e57f4efb0b62b028589d": "2f763f29fb027bec1ccde9569c6ad399",
".git/objects/74/8e019d96f7a8ca9325509d2adf525177970dfd": "7c4acd58a7535d31145fd7c22dc76d77",
".git/objects/77/91c8c24b3bd2b30bf92c5c2a59a1c7139290f7": "b2ff52b2be27f80cac7da41ee39bf01a",
".git/objects/77/f7120e4c45d13a6f1d509a77ba82bfe8f29b24": "b247fb05542145d1ac726e7c0a68e7cf",
".git/objects/7a/c734e8c95385bf3f15f90d05197b9e3262a25a": "dd0e1fb458f4e5c554837d3adb85f61a",
".git/objects/7f/e0ff74d46ec6acbd8c200708083eb700142975": "7c08463fb68c7816ae78c897cb0d7512",
".git/objects/83/1b47e57228b62a20d90c53e29ba1b11bf3d31f": "0430d23958400064a9f1b8704b6b4d47",
".git/objects/88/2f77c1938d62415e02613da3571d517944016e": "7d03ef290800b7f65f5e401f20eea32d",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8b/4d3f12916569f438b3022827fa02252d519401": "39471088e062162545821117c5ebe285",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/98/e34c0bcde57d9ac4ecf71e3793b6c921e90de6": "c262c5e6d88b8599df4fb7a399fa3385",
".git/objects/9f/3a246c25519abf0d766bf936fce1b202a8b7fe": "43bf99dded484dd8f7ae13b25915e4f5",
".git/objects/a1/3f272578bacbf8b7bcf2ba349f5f18d31d0a2d": "c3ebbedeb701a7e04f5610783669bfde",
".git/objects/a1/6b5a91f83d69a67e00e112dececb2c7d2e53e7": "1e708b2ae1a9032b2f5629a40aba6f3f",
".git/objects/a1/fcc67fd4c4d70bfe7ec4bcff6935219fddfaaf": "6e3a6d15237779f0402fe88898855dc1",
".git/objects/a3/f21e43ab2d03c0f015840b3852a7610f160f31": "4f9eb9768724c055a646c10e05bff555",
".git/objects/a5/a47d206dbd17235a0a5cd09862b922220a332d": "ca1916d0cec5eec187ecf6e08a61af2b",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/aa/f9784fd6f35535f3728f44805806a9916875c5": "f250b13aab6083ab180e562395adbc07",
".git/objects/ae/4dac1ba7f5819ce0388fe33c7a641478a4de7c": "95e74dc7c009c50b0318ee890e11e2dc",
".git/objects/b0/481ee5bb0a9196c58a9ead1dfc16a47180289c": "dae41b9cbe26216dbf815a134d102293",
".git/objects/b5/3a1c9ab192521c928317c9c55a87dcfb4b44c4": "bea9bf6a8ac885a5377e7d74213458b9",
".git/objects/b8/b89793ccd23114f47086e6d831374c7cf7622d": "6aa3d6ee579e2e3b943a7634a7508025",
".git/objects/b9/17c3a4be74de0f14b210a7c3f452b5709db8d7": "1e6b6c2a4b0709b941ed9985787d0c4e",
".git/objects/bd/3d1d06c6102f732d5d2cc9f47aa80b93408309": "9d61bcc6e9ecfec219449e107da0250b",
".git/objects/bf/2212c3007ea0b7ea6d40bb0db6a31499eaa620": "4aac0f613b7f2eb98f344f23732603f6",
".git/objects/c0/28b8e32b8300a1647ae39b34e8863a4e2797bd": "7729287645036cc17d6c99ed93397884",
".git/objects/c0/79bb365eb232b74a771faccaf78b1c86cca4b5": "a7d99d26ab2725ad4c8b6036157cb3f6",
".git/objects/c1/5f8c0e60b3b4d19c5c070995cd00e4beddc343": "5b5c885dba3eb4784ada23335b677b63",
".git/objects/c9/4f0da13635e55d6aa291f281b7fdfd2b416008": "5cbd92f26a098b8eddc3e01928421feb",
".git/objects/cb/525055a40f1426f2d886d405306c0896b22db2": "e64c726885e680645b90b8c90d536f7a",
".git/objects/cc/e27b0c8bcc02b56f9501b3336ff35e286e401b": "e9d6de4b7ebc27db74e9162909cc2ef1",
".git/objects/ce/5cb34624584a81e49e770dcf4286a11a525a01": "fdf31ebc0ec010e1176afc278ba3e3fb",
".git/objects/d1/606babcd83219ccf18fbde4cfa6d914bb59d7a": "91751af58f4b6ba02d558a81be1ae9a8",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d8/07512cad19ef1665dccf2fc07e2195c0aa9671": "ce6b04fb1ec8ed70c6adb30bbb6016a8",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/da/0d39e8e1ec8a4f357a46ceae633c503d6f71e6": "f359b6090ad75a20da3b72d5576968ae",
".git/objects/da/46390fb4129b946e3e31257115dda7fc97f0e3": "48aa3463caed6f9043f8035197bb1dcd",
".git/objects/db/40c5c9f65122591d13d2c06e7ff7142fd5350a": "052b80781103b87acd0710f78c9233a6",
".git/objects/db/5aee33a7990ee286e83a4e78c386ea9a33209a": "f2d9968837390f6631fd90b8fbdfdcc6",
".git/objects/e0/ba12aeeb26af13d7d1658dc03635caa7dc83bd": "6ed7e4b427ad816ef7dc8ee4a00a71c1",
".git/objects/e8/b46b219ca9d464b9899b6ac838de9b2b467a08": "d312d3af45b61be2f7baab93fd673623",
".git/objects/ea/2eb999781458ca2efcca33a80061a5059fb181": "5a1a253f1efe4ce7496a90bc1e9df8ae",
".git/objects/ec/04296f26e10ef067c49653ea64ce9ebfc68fcf": "417eca17f9d2702976ddd671d13097a7",
".git/objects/ed/6e4144b959dd9aad0da02377b1554239e99195": "ac8f23512d82d650be30c6ecd7e2b818",
".git/objects/ee/ceabcd2612ff26c943dc10d11f9453f1bc499a": "d4ac2fcdbdc61a202bcb9611e7ce3b8d",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f1/00394611a6449089b8c351ad8909390712c4d4": "744aa697a52e278816c889efc46ec375",
".git/objects/f1/215e1dd6edf01b81158cb2422250935bfd3590": "aa8b4a9d78c676beee324eb25e2b0fb3",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f6/a94867e6360858b118653af8eceb40fc688667": "11b3f0062d06ad935e5dbe55192e8a3e",
".git/objects/f7/31af93a40e0071e1cab1bb9b29bce0939da885": "6dfae5f39342bf115ff715ca5428d02f",
".git/objects/fb/4be249f6f25624f2a4249dfc53131b6d5bf6b8": "1011047ef7f47072ac46dbb93f3b660d",
".git/objects/fc/6a74b8a8077750f530cddaf6ac66c05db48268": "6f32e9d444d01213b80d1102860a3c2a",
".git/refs/heads/gh-pages": "d6d9cf782c9d9ed032b7773278687801",
".git/refs/remotes/origin/gh-pages": "d6d9cf782c9d9ed032b7773278687801",
"assets/AssetManifest.bin": "0bd4d9bbe07b58897f9dbf37dc85ef3b",
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
"assets/NOTICES": "5a3f9d6e5e9ea647454fcf9b33d4db2a",
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
"CNAME": "f8f62c084655eae27ea9c775349baec5",
"favicon.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "00b1899cc6b987acf9b916138319f9a0",
"icons/Icon-192.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"icons/Icon-512.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"icons/Icon-maskable-192.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"icons/Icon-maskable-512.jpg": "f7cb2bf5824a8412bef964748cb898f5",
"index.html": "3cf6290722a909e09fc0830921d003f7",
"/": "3cf6290722a909e09fc0830921d003f7",
"main.dart.js": "4668067943a4163269f8898ab5adb967",
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
