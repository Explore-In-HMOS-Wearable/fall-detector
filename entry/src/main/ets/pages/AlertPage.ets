// AlertPage.ets

import type { FallEvent } from '../store/FallStore';

const EMPTY_EVENT: FallEvent = { ts: 0, accPeak: 0, gyroPeak: 0 };

@Builder
export function AlertBuilder(): void {
  AlertPage();
}

@Component
struct AlertPage {
  private pathStack: NavPathStack = new NavPathStack();
  @State event: FallEvent = EMPTY_EVENT;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 8 }) {
          Text('⚠️ FALL DETECTED')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 18 });

          Text(`accPeak: ${this.event.accPeak.toFixed(1)} m/s²`).fontSize(14).opacity(0.9);
          Text(`gyroPeak: ${this.event.gyroPeak.toFixed(1)} rad/s`).fontSize(14).opacity(0.9);

          Button("I'M OK")
            .backgroundColor(Color.Red)
            .width('50%')
            .height(23)
            .onClick(() => this.pathStack.pop());
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#2A0000');
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