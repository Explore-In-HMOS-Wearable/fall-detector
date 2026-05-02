import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class HapticService {

  async playClick(): Promise<void> {
    try {
      vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.clock.timer',
        count: 1
      }, {
        usage: 'touch'
      });
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      console.error(`playClick failed. Code: ${e.code}, message: ${e.message}`);
    }
  }

  async playStateChange(): Promise<void> {
    const effectId = 'haptic.switch.soft';
    try {
      const isSupported = await vibrator.isSupportEffect(effectId);
      if (isSupported) {
        await vibrator.startVibration({
          type: 'preset',
          effectId: effectId,
          count: 1
        }, {
          usage: 'touch'
        });
      } else {
        await vibrator.startVibration({
          type: 'time',
          duration: 100
        }, {
          usage: 'touch'
        });
      }
    } catch (err) {
      this.logError('playStateChange', err);
    }
  }

  async playAlert(): Promise<void> {
    const effectId = 'haptic.alarm.clock';
    try {
      const isSupported = await vibrator.isSupportEffect(effectId);
      if (isSupported) {
        await vibrator.startVibration({
          type: 'preset',
          effectId: effectId,
          count: 3
        }, {
          usage: 'alarm'
        });
      } else {
        // Fallback to pattern-based vibration
        await vibrator.startVibration({
          type: 'time',
          duration: 1000
        }, {
          usage: 'alarm'
        });
      }
    } catch (err) {
      this.logError('playAlert', err);
    }
  }

  async playSuccess(): Promise<void> {
    const effectId = 'haptic.charging';
    try {
      const isSupported = await vibrator.isSupportEffect(effectId);
      if (isSupported) {
        await vibrator.startVibration({
          type: 'preset',
          effectId: effectId,
          count: 1
        }, {
          usage: 'notification'
        });
      }
    } catch (err) {
      this.logError('playSuccess', err);
    }
  }

  async stop(): Promise<void> {
    try {
      await vibrator.stopVibration(vibrator.VibratorStopMode.VIBRATOR_STOP_MODE_PRESET);
      await vibrator.stopVibration(vibrator.VibratorStopMode.VIBRATOR_STOP_MODE_TIME);
    } catch (err) {
      this.logError('stop', err);
    }
  }

  private logError(method: string, e: BusinessError): void {
    console.error(`HapticService.${method} failed. Code: ${e.code}, message: ${e.message}`);
  }
}

export const hapticService = new HapticService();
