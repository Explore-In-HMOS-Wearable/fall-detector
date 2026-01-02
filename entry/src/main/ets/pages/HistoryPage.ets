import { fallStore, type FallEvent } from '../store/FallStore';

@Builder
export function HistoryBuilder(): void {
  HistoryPage();
}

@Component
struct HistoryPage {
  private pathStack: NavPathStack = new NavPathStack();
  @State events: FallEvent[] = [];

  private refresh(): void {
    this.events = fallStore.getEvents();
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
      Column({ space: 10 }) {
        Text('History')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 12 });

        List() {
          ForEach(this.events, (e: FallEvent) => {
            ListItem() {
              Column({ space: 2 }) {
                Text(`Fall • ${this.fmt(e.ts)}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium);

                Text(`acc ${e.accPeak.toFixed(1)} | gyro ${e.gyroPeak.toFixed(1)}`)
                  .fontSize(12)
                  .opacity(0.8);
              }
              .padding(10)
              .borderRadius(12)
              .backgroundColor('#1A1A1A')
              .width('100%');
            }
          }, (e: FallEvent) => e.ts.toString());
        }
        .width('92%')
        .layoutWeight(1);

        Column({ space: 10 }) {
          Button('Clear')
            .backgroundColor('#54101D')
            .width('36%')
            .height(20)
            .onClick(() => {
              fallStore.clearEvents();
              this.events = [];
            });

          Button('Back')
            .backgroundColor('#54101D')
            .width('36%')
            .height(20)
            .onClick(() => this.pathStack.pop());
        }
        .width('92%')
        .margin({ bottom: 12 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0E0E0E')
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
