// AlertPage.ets

import type { FallEvent } from '../store/FallStore';
import { hapticService } from '../services/HapticService';
import { common } from '@kit.AbilityKit';

const EMPTY_EVENT: FallEvent = { ts: 0, accPeak: 0, gyroPeak: 0 };

@Builder
export function AlertBuilder(): void {
  AlertPage();
}

@Component
struct AlertPage {
  private pathStack: NavPathStack = new NavPathStack();
  @State event: FallEvent = EMPTY_EVENT;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Column({ space: 8 }) {
        Blank()

        Text($r('app.string.title_alert'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center);

        Column({ space: 2 }) {
          Text(`${this.context.resourceManager.getStringSync($r('app.string.label_acc').id)}: ${this.event.accPeak.toFixed(1)}`).fontSize(12).opacity(0.9);
          Text(`${this.context.resourceManager.getStringSync($r('app.string.label_gyro').id)}: ${this.event.gyroPeak.toFixed(1)}`).fontSize(12).opacity(0.9);
        }
        .margin({ top: 4, bottom: 8 });

        Button($r('app.string.btn_ok'))
          .backgroundColor('#1D3B24')
          .fontColor(Color.White)
          .width('80%')
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .borderRadius(22)
          .onClick(() => {
            hapticService.playClick();
            this.pathStack.pop();
          });

        Blank() // Pushes content from bottom
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#3A0000')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center);
    }
    .hideTitleBar(true, false)
    .hideToolBar(true, false)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      if (context.pathInfo.param) {
        this.event = context.pathInfo.param as FallEvent;
      }
    });
  }
}
