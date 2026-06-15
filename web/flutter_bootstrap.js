{{flutter_js}}
{{flutter_build_config}}

const bootLoader = document.getElementById('loading');

function hideBootLoader() {
  if (!bootLoader) return;
  bootLoader.classList.add('paedia-boot--hide');
  window.setTimeout(() => bootLoader.remove(), 280);
}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      useColorEmoji: true,
    });
    hideBootLoader();
    await appRunner.runApp();
  },
});
