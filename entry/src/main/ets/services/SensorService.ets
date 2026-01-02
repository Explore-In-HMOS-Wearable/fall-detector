import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import cryptoFramework from '@ohos.security.cryptoFramework';

type Vec3Cb = (x: number, y: number, z: number) => void;

export class SensorService {
  private accelCb: Vec3Cb = () => {};
  private gyroCb: Vec3Cb = () => {};
  private started: boolean = false;
  private mockEnabled: boolean = true;
  private mockTimerId: number = -1;
  private mockFallUntilTs: number = 0;
  private mockImmobileUntilTs: number = 0;
  // Auto fall - mock -
  private autoMockFall: boolean = true;
  private autoMockEveryMs: number = 8000;
  private lastAutoMockTs: number = 0;
  private rng = cryptoFramework.createRandom();
  private async secureMathRandom(): Promise<number> {
    const blob = await this.rng.generateRandom(4);
    const d = blob.data;
    const u32: number = ((((d[0] << 24) >>> 0) | (d[1] << 16) | (d[2] << 8) | d[3]) >>> 0);
    return u32 / 4294967296;
  }
  private async secureCenteredRandom(): Promise<number> {
    return (await this.secureMathRandom()) - 0.5;
  }

  private mockBusy: boolean = false;

  setAutoMockFallEnabled(mock: boolean): void {
    this.autoMockFall = mock;
  }

  setAutoMockEveryMs(ms: number): void {
    this.autoMockEveryMs = ms;
  }

  onAccelerometer(cb: Vec3Cb): void {
    this.accelCb = cb;
  }

  onGyroscope(cb: Vec3Cb): void {
    this.gyroCb = cb;
  }

  setMockEnabled(v: boolean): void {
    this.mockEnabled = v;
  }

  triggerMockFall(): void {
    const now: number = Date.now();
    this.mockFallUntilTs = now + 250;
    this.mockImmobileUntilTs = now + 2000;
  }

  start(): void {
    if (this.started) {
      return;
    }
    this.started = true;

    if (this.mockEnabled) {
      this.startMock();
      return;
    }

    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data) => {
        this.accelCb(data.x, data.y, data.z);
      });
    } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`ACCEL on failed. Code: ${e.code}, message: ${e.message}`);
    }

    try {
      sensor.on(sensor.SensorId.GYROSCOPE, (data) => {
        this.gyroCb(data.x, data.y, data.z);
      });
    } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`GYRO on failed. Code: ${e.code}, message: ${e.message}`);
    }
  }

  stop(): void {
    if (!this.started){
      return;
    }
    this.started = false;
    this.stopMock();

    try { sensor.off(sensor.SensorId.ACCELEROMETER); } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`ACCEL off failed. Code: ${e.code}, message: ${e.message}`);
    }

    try { sensor.off(sensor.SensorId.GYROSCOPE); } catch (error) {
      const e: BusinessError = error as BusinessError;
      console.error(`GYRO off failed. Code: ${e.code}, message: ${e.message}`);
    }
  }

  private startMock(): void {
    this.stopMock();
    this.mockTimerId = setInterval(() => {
      if (this.mockBusy) {
        return;
      }
      this.mockBusy = true;

      this.mockTick()
        .finally(() => { this.mockBusy = false; });
    }, 100);
  }

  private async mockTick(): Promise<void> {
    const now: number = Date.now();
    if (this.autoMockFall &&
      now - this.lastAutoMockTs >= this.autoMockEveryMs &&
      now > this.mockImmobileUntilTs) {
      this.lastAutoMockTs = now;
      this.triggerMockFall();
    }

    let ax: number = (await this.secureCenteredRandom()) * 0.2;
    let ay: number = (await this.secureCenteredRandom()) * 0.2;
    let az: number = 1.0 + (await this.secureCenteredRandom()) * 0.2;
    let gx: number = (await this.secureCenteredRandom()) * 0.1;
    let gy: number = (await this.secureCenteredRandom()) * 0.1;
    let gz: number = (await this.secureCenteredRandom()) * 0.1;

    // impact phase: big accel + big gyro
    if (now <= this.mockFallUntilTs) {
      ax = (await this.secureCenteredRandom()) * 8.0;
      ay = (await this.secureCenteredRandom()) * 8.0;
      az = 26.0 + (await this.secureCenteredRandom()) * 3.0;
      gx = (await this.secureCenteredRandom()) * 3.0;
      gy = (await this.secureCenteredRandom()) * 3.0;
      gz = 6.0 + (await this.secureCenteredRandom()) * 1.0;
    }
    // immobile phase: very small accel/gyro mags
    if (now > this.mockFallUntilTs && now <= this.mockImmobileUntilTs) {
      ax = (await this.secureCenteredRandom()) * 0.05;
      ay = (await this.secureCenteredRandom()) * 0.05;
      az = 0.9 + (await this.secureCenteredRandom()) * 0.05;
      gx = (await this.secureCenteredRandom()) * 0.02;
      gy = (await this.secureCenteredRandom()) * 0.02;
      gz = (await this.secureCenteredRandom()) * 0.02;
    }
    this.accelCb(ax, ay, az);
    this.gyroCb(gx, gy, gz);
  }
  private stopMock(): void {
    if (this.mockTimerId >= 0) {
      clearInterval(this.mockTimerId);
      this.mockTimerId = -1;
    }
    this.lastAutoMockTs = 0;
  }
}

export const sensorService: SensorService = new SensorService();
