// Index.ets
import { fallStore, DEFAULT_CONFIG_JSON, DEFAULT_PREFS_JSON } from '../store/FallStore';

@Entry
@Component
struct Index {
  private stack: NavPathStack = new NavPathStack();
  private started: boolean = false;

  aboutToAppear(): void {
    PersistentStorage.persistProp('fall_events', JSON.stringify([]));
    PersistentStorage.persistProp('fall_config', DEFAULT_CONFIG_JSON);
    PersistentStorage.persistProp('fall_prefs', DEFAULT_PREFS_JSON);

    fallStore.init();
  }

  build() {
    Navigation(this.stack) {
    }
    .mode(NavigationMode.Stack)
    .hideNavBar(true)
    .onAppear(() => {
      if (this.started) {
        return;
      }
      this.started = true;
      this.stack.pushPathByName('Home', null, false);
    })
    .width('100%')
    .height('100%');
  }
}