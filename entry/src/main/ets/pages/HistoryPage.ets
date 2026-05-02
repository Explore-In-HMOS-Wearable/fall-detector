import { fallStore, type FallEvent } from '../store/FallStore';
import { hapticService } from '../services/HapticService';
import { common } from '@kit.AbilityKit';

@Builder
export function HistoryBuilder(): void {
  HistoryPage();
}

@Component
struct HistoryPage {
  private pathStack: NavPathStack = new NavPathStack();
  @State events: FallEvent[] = [];
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  async refresh(): Promise<void> {
    this.events = await fallStore.getEvents();
  }

  private fmt(ts: number): string {
    const d: Date = new Date(ts);
    const hh: string = d.getHours().toString().padStart(2, '0');
    const mm: string = d.getMinutes().toString().padStart(2, '0');
    const ss: string = d.getSeconds().toString().padStart(2, '0');
    return `${hh}:${mm}:${ss}`;
  }

  build() {
    NavDestination() {
      Column({ space: 6 }) {
        Text($r('app.string.title_history'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 10 });

        if (this.events.length === 0) {
          Column({ space: 8 }) {
            Text('🛡️').fontSize(30)
            Text($r('app.string.history_empty'))
              .fontSize(14).fontColor('#666666')
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)

        } else {
          List({ space: 4 }) {
            ForEach(this.events, (e: FallEvent) => {
              ListItem() {
                Column({ space: 2 }) {
                  Text(`${this.context.resourceManager.getStringSync($r('app.string.status_detected').id)} • ${this.fmt(e.ts)}`)
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium);

                  Text(`${this.context.resourceManager.getStringSync($r('app.string.label_acc').id)} ${e.accPeak.toFixed(1)} | ${this.context.resourceManager.getStringSync($r('app.string.label_gyro').id)} ${e.gyroPeak.toFixed(1)}`)
                    .fontSize(11)
                    .opacity(0.8);
                }
                .padding(8)
                .borderRadius(12)
                .backgroundColor('#1A1A1A')
                .width('100%');
              }
            }, (e: FallEvent) => e.ts?.toString() || e.ts.toString());
          }
          .width('90%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .focusable(true)
          .defaultFocus(true);
        }

        Row({ space: 6 }) {
          Button($r('app.string.btn_clear'))
            .backgroundColor('#8B0000')
            .width('40%') // Reduced width
            .height(30)
            .fontSize(11)
            .onClick(async () => {
              hapticService.playClick();
              await fallStore.clearEvents();
              this.events = [];
            });

          Button($r('app.string.btn_back'))
            .backgroundColor('#2A2A2A')
            .width('40%') // Reduced width
            .height(30)
            .fontSize(11)
            .onClick(() => {
              hapticService.playClick();
              this.pathStack.pop();
            });
        }
        .width('65%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 20 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
      .alignItems(HorizontalAlign.Center);
    }
    .hideTitleBar(true, false)
    .hideToolBar(true, false)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onAppear(() => {
      this.refresh();
    });
  }
}
