/* Service worker de notificações do chat.
 *
 * Não importa o SDK do Firebase (viria de www.gstatic.com, que a CSP do site
 * não libera para scripts): a mensagem do FCM chega como evento `push` comum e
 * é exibida aqui. O texto é genérico de propósito ("Nova mensagem de X") —
 * conteúdo clínico não aparece na tela bloqueada.
 */
self.addEventListener('push', (event) => {
  let payload = {};
  try { payload = event.data ? event.data.json() : {}; } catch (e) { payload = {}; }
  const n = payload.notification || {};
  const data = payload.data || {};
  const title = n.title || 'Pets';
  event.waitUntil(self.registration.showNotification(title, {
    body: n.body || 'Você tem uma nova mensagem.',
    tag: n.tag || data.conversaId || 'pets-chat',
    icon: '/android-chrome-192x192.png',
    badge: '/android-chrome-192x192.png',
    data: { link: (payload.fcmOptions && payload.fcmOptions.link) || data.link || '/chat' },
  }));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const link = (event.notification.data && event.notification.data.link) || '/chat';
  event.waitUntil((async () => {
    const all = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    const open = all.find((c) => c.url.startsWith(self.location.origin));
    if (open) {
      await open.focus();
      open.navigate(link).catch(() => {});
      return;
    }
    await self.clients.openWindow(link);
  })());
});
