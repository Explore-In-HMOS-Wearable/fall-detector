import { sensorService } from '../services/SensorService';
import { hapticService } from '../services/HapticService';
import { detectionEngine } from '../services/DetectionEngine';
import { fallStore } from '../store/FallStore';
import type { FallEvent } from '../store/FallStore';

@Builder
export function HomeBuilder(): void {
  HomePage();
}

@Component
struct HomePage {
  private pathStack: NavPathStack = new NavPathStack();
  private scroller: Scroller = new Scroller();

  @State accText: string = '0.0, 0.0, 0.0';
  @State gyroText: string = '0.0, 0.0, 0.0';
  @State statusText: Resource = $r('app.string.status_stopped');
  @State running: boolean = false;

  async aboutToAppear(): Promise<void> {
    const prefs = await fallStore.getPrefs();
    sensorService.setMockEnabled(prefs.mockEnabled);
    const config = await fallStore.getConfig();
    detectionEngine.configure(config);

    sensorService.onAccelerometer((x: number, y: number, z: number) => {
      this.accText = `${x.toFixed(1)}, ${y.toFixed(1)}, ${z.toFixed(1)}`;
      detectionEngine.processAccel(x, y, z);
    });

    sensorService.onGyroscope((x: number, y: number, z: number) => {
      this.gyroText = `${x.toFixed(1)}, ${y.toFixed(1)}, ${z.toFixed(1)}`;
      detectionEngine.processGyro(x, y, z);
    });

    detectionEngine.onFallDetected((e: FallEvent) => {
      fallStore.addEvent(e);
      this.statusText = $r('app.string.status_detected');
      hapticService.playAlert(); // Emergency haptic feedback
      this.pathStack.pushPathByName('Alert', e, true);
    });
  }

  aboutToDisappear(): void {
    sensorService.onAccelerometer(() => {});
    sensorService.onGyroscope(() => {});
    this.stopMonitoring();
  }

  private startMonitoring(): void {
    if (this.running) {
      return;
    }
    this.running = true;
    this.statusText = $r('app.string.status_monitoring');
    sensorService.setAutoMockFallEnabled(true);
    sensorService.start();
  }

  private stopMonitoring(): void {
    if (!this.running) {
      return;
    }
    this.running = false;
    this.statusText = $r('app.string.status_stopped');
    sensorService.stop();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll(this.scroller) {
          Column({ space: 4 }) {
            Text($r('app.string.app_name'))
              .margin({ top: 10 })
              .fontSize(18)
              .fontWeight(FontWeight.Bolder)
              .width('100%')
              .textAlign(TextAlign.Center);

            Text(this.statusText)
              .fontSize(12)
              .opacity(0.85)
              .width('100%')
              .textAlign(TextAlign.Center);

            Column() {
              Column({ space: 2 }) {
                Text($r('app.string.label_acc'))
                  .fontSize(11)
                  .opacity(0.85);
                Text(this.accText)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center);

              Column({ space: 2 }) {
                Text($r('app.string.label_gyro'))
                  .fontSize(11)
                  .opacity(0.85)
                  .margin({ top: 4 });
                Text(this.gyroText)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center);
            }
            .width('100%')
            .padding(8)
            .borderRadius(12)
            .backgroundColor('#1A1A1A')
            .margin({ top: 6 });
          }
          .width('100%')
          .padding({ left: 10, right: 10 });
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .onDigitalCrown((event: CrownEvent) => {
          this.scroller.scrollBy(0, -event.angularVelocity * 2);
        })
        .focusable(true)
        .defaultFocus(true);

        Column({ space: 6 }) {
          Row({ space: 6 }) {
            Button(this.running ? $r('app.string.btn_stop') : $r('app.string.btn_start'))
              .backgroundColor(this.running ? '#8B0000' : '#1D3B24')
              .fontSize(11)
              .layoutWeight(1)
              .height(28)
              .onClick(() => {
                hapticService.playClick();
                if (this.running) {
                  this.stopMonitoring();
                } else {
                  this.startMonitoring();
                }
              });

            Button($r('app.string.btn_fall'))
              .backgroundColor('#54101D')
              .fontSize(11)
              .layoutWeight(1)
              .height(28)
              .onClick(async () => {
                const prefs = await fallStore.getPrefs();
                if (this.running && prefs.mockEnabled) {
                  hapticService.playClick();
                  sensorService.triggerMockFall();
                }
              });
          }
          .width('80%');

          Row({ space: 6 }) {
            Button($r('app.string.btn_history'))
              .backgroundColor('#2A2A2A')
              .fontSize(10)
              .layoutWeight(1)
              .height(28)
              .onClick(() => {
                hapticService.playClick();
                this.pathStack.pushPathByName('History', null, true);
              });

            Button($r('app.string.btn_settings'))
              .backgroundColor('#2A2A2A')
              .fontSize(10)
              .layoutWeight(1)
              .height(28)
              .onClick(() => {
                hapticService.playClick();
                this.pathStack.pushPathByName('Settings', null, true);
              });
          }
          .width('63%');
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 20 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000');
    }
    .hideTitleBar(true, false)
    .hideToolBar(true, false)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    });
  }
}
