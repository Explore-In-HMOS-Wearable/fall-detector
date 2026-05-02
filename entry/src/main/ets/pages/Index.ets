// Index.ets
import { fallStore } from '../store/FallStore';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  private stack: NavPathStack = new NavPathStack();
  private started: boolean = false;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    await fallStore.init(this.context);
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