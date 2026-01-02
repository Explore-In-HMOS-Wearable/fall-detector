import { sensorService } from '../services/SensorService';
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

  @State accText: string = '0.0, 0.0, 0.0';
  @State gyroText: string = '0.0, 0.0, 0.0';
  @State statusText: string = 'Stopped';
  @State running: boolean = false;

  aboutToAppear(): void {
    sensorService.setMockEnabled(fallStore.getPrefs().mockEnabled);
    detectionEngine.configure(fallStore.getConfig());
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
      this.statusText = 'Fall detected!';
      this.pathStack.pushPathByName('Alert', e, true);
    });
  }

  aboutToDisappear(): void {
    this.stopMonitoring();
  }

  private startMonitoring(): void {
    if (this.running) {
      return;
    }
    this.running = true;
    this.statusText = 'Monitoring';
    sensorService.setAutoMockFallEnabled(true);
    sensorService.start();
  }

  private stopMonitoring(): void {
    if (!this.running) {
      return;
    }
    this.running = false;
    this.statusText = 'Stopped';
    sensorService.stop();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 8 }) {
            Text('Fall Detector')
              .margin({ top: 20 })
              .fontSize(21)
              .fontWeight(FontWeight.Bolder)
              .width('100%')
              .textAlign(TextAlign.Center);

            Text(this.statusText)
              .fontSize(14)
              .opacity(0.85)
              .width('100%')
              .textAlign(TextAlign.Center);

            Column() {
              Row({ space: 15 }) {
                Column({ space: 4 }) {
                  Text('Accelerometer')
                    .fontSize(12)
                    .opacity(0.85);
                  Text(this.accText)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium);
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);

                Column({ space: 4 }) {
                  Text('Gyroscope')
                    .fontSize(12)
                    .opacity(0.85);
                  Text(this.gyroText)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium);
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.End);
              }
              .width('100%');
            }
            .width('100%')
            .padding(12)
            .borderRadius(14)
            .backgroundColor('#1A1A1A')
            .margin({ top: 8 });
          }
          .width('100%')
          .padding({ left: 11, right: 11 });
        }
        .layoutWeight(1);

        Row({ space: 10 }) {
          Button(this.running ? 'Stop' : 'Start')
            .backgroundColor('#54101D')
            .fontSize(9)
            .width('27%')
            .height(35)
            .onClick(() => {
              if (this.running) {
                this.stopMonitoring();
              } else {
                this.startMonitoring();
              }
            });

          Button('Fall')
            .backgroundColor('#54101D')
            .fontSize(9)
            .width('27%')
            .height(35)
            .enabled(this.running && fallStore.getPrefs().mockEnabled)
            .opacity(this.running && fallStore.getPrefs().mockEnabled ? 1:0.4)
            .onClick(() => sensorService.triggerMockFall());

          Button('History')
            .backgroundColor('#54101D')
            .fontSize(9)
            .width('27%')
            .height(35)
            .onClick(() => this.pathStack.pushPathByName('History', null, true));
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 12 });

        Row({ space: 10 }) {
          Button('Settings')
            .backgroundColor('#54101D')
            .fontSize(9)
            .width('27%')
            .height(35)
            .onClick(() => this.pathStack.pushPathByName('Settings', null, true));
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 12 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#0E0E0E');
    }
    .hideTitleBar(true, false)
    .hideToolBar(true, false)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    });
  }
}