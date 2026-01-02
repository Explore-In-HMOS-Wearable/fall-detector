//SettingsPage.ets

import { fallStore, type FallConfig } from '../store/FallStore';
import { sensorService } from '../services/SensorService';

@Builder
export function SettingsBuilder(): void {
  SettingsPage();
}

@Component
struct SettingsPage {
  private pathStack: NavPathStack = new NavPathStack();
  @State cfg: FallConfig = fallStore.getConfig();

  @State mockEnabled: boolean = fallStore.getPrefs().mockEnabled;

  private save(): void {
    fallStore.setConfig(this.cfg);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text('Settings')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 18 });

          Row({ space: 8 }) {
            Text('Mock Mode')
              .fontSize(14)
              .layoutWeight(1);

            Toggle({ type: ToggleType.Switch, isOn: this.mockEnabled })
              .onChange((v: boolean) => {
                this.mockEnabled = v;
                fallStore.setPrefs({ mockEnabled: v });
                sensorService.setMockEnabled(v);
              });
          }
          .width('92%')
          .padding(12)
          .borderRadius(14)
          .backgroundColor('#1A1A1A');

          Column({ space: 3 }) {
            Text(`Impact Threshold: ${this.cfg.impactThreshold.toFixed(1)}`)
              .fontSize(14);
            Slider({ value: this.cfg.impactThreshold, min: 10, max: 40 })
              .selectedColor('#FF4D8D')
              .trackColor('#2A2A2A')
              .onChange((v: number) => {
                this.cfg.impactThreshold = v; this.save();
              });

            Text(`Gyro Threshold: ${this.cfg.gyroThreshold.toFixed(1)}`)
              .fontSize(14)
              .margin({ top: 6 });
            Slider({ value: this.cfg.gyroThreshold, min: 1, max: 10 })
              .selectedColor('#00D1FF')
              .trackColor('#2A2A2A')
              .onChange((v: number) => {
                this.cfg.gyroThreshold = v; this.save();
              });

            Text(`Immobile Time: ${this.cfg.immobileTimeMs} ms`)
              .fontSize(14)
              .margin({ top: 6 });
            Slider({ value: this.cfg.immobileTimeMs, min: 300, max: 2500 })
              .selectedColor('#8B5CF6')
              .trackColor('#2A2A2A')
              .onChange((v: number) => {
                this.cfg.immobileTimeMs = Math.floor(v); this.save();
              });
          }
          .padding(12)
          .borderRadius(14)
          .backgroundColor('#1A1A1A')
          .width('92%');

          Button('Back')
            .backgroundColor('#54101D')
            .width('40%')
            .height(46)
            .margin({ top: 10, bottom: 14 })
            .onClick(() => this.pathStack.pop());
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);
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