//SettingsPage.ets

import { fallStore, type FallConfig } from '../store/FallStore';
import { sensorService } from '../services/SensorService';
import { hapticService } from '../services/HapticService';

@Builder
export function SettingsBuilder(): void {
  SettingsPage();
}

@Component
struct SettingsPage {
  private pathStack: NavPathStack = new NavPathStack();
  private scroller: Scroller = new Scroller();
  @State cfg: FallConfig = {
    impactThreshold: 22,
    gyroThreshold: 4.5,
    immobileTimeMs: 1200,
    immobileAcc: 1.3,
    immobileGyro: 0.6
  };

  @State mockEnabled: boolean = true;

  async aboutToAppear(): Promise<void> {
    this.cfg = await fallStore.getConfig();
    const prefs = await fallStore.getPrefs();
    this.mockEnabled = prefs.mockEnabled;
  }

  private save(): void {
    fallStore.setConfig(this.cfg);
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column({ space: 8 }) {
          Text($r('app.string.title_settings'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 10 });

          Row({ space: 6 }) {
            Text($r('app.string.setting_mock'))
              .fontSize(13)
              .layoutWeight(1);

            Toggle({ type: ToggleType.Switch, isOn: this.mockEnabled })
              .onChange((v: boolean) => {
                hapticService.playStateChange();
                this.mockEnabled = v;
                fallStore.setPrefs({ mockEnabled: v });
                sensorService.setMockEnabled(v);
              })
              .width(36)
              .height(20);
          }
          .width('90%')
          .padding(8)
          .borderRadius(12)
          .backgroundColor('#1A1A1A');

          Column({ space: 4 }) {
            Text($r('app.string.setting_impact', this.cfg.impactThreshold.toFixed(1)))
              .fontSize(12);
            Slider({ value: this.cfg.impactThreshold, min: 10, max: 40 })
              .selectedColor('#FF4D8D')
              .trackColor('#2A2A2A')
              .height(24)
              .onChange((v: number) => {
                this.cfg.impactThreshold = v; this.save();
              });

            Text($r('app.string.setting_gyro', this.cfg.gyroThreshold.toFixed(1)))
              .fontSize(12)
              .margin({ top: 4 });
            Slider({ value: this.cfg.gyroThreshold, min: 1, max: 10 })
              .selectedColor('#00D1FF')
              .trackColor('#2A2A2A')
              .height(24)
              .onChange((v: number) => {
                this.cfg.gyroThreshold = v; this.save();
              });

            Text($r('app.string.setting_immobile', this.cfg.immobileTimeMs))
              .fontSize(12)
              .margin({ top: 4 });
            Slider({ value: this.cfg.immobileTimeMs, min: 300, max: 2500 })
              .selectedColor('#8B5CF6')
              .trackColor('#2A2A2A')
              .height(24)
              .onChange((v: number) => {
                this.cfg.immobileTimeMs = Math.floor(v); this.save();
              });
          }
          .padding(8)
          .borderRadius(12)
          .backgroundColor('#1A1A1A')
          .width('90%');

          Button($r('app.string.btn_back'))
            .backgroundColor('#2A2A2A')
            .width('50%')
            .height(30)
            .fontSize(11)
            .margin({ top: 8, bottom: 20 })
            .onClick(() => {
              hapticService.playClick();
              this.pathStack.pop();
            });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
      .scrollBar(BarState.Off)
      .onDigitalCrown((event: CrownEvent) => {
        this.scroller.scrollBy(0, -event.angularVelocity * 2);
      })
      .focusable(true)
      .defaultFocus(true);
    }
    .hideTitleBar(true, false)
    .hideToolBar(true, false)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    });
  }
}
