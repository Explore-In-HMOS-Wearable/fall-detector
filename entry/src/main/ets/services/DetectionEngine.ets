
// DetectionEngine.ets

import type { FallConfig, FallEvent } from '../store/FallStore';

export class DetectionEngine {
  private cfg: FallConfig = {
    impactThreshold: 22.0,
    gyroThreshold: 4.5,
    immobileTimeMs: 1200,
    immobileAcc: 1.3,
    immobileGyro: 0.6
  };

  private lastImpactTs: number = 0;
  private orientationChanged: boolean = false;
  private lastAccMag: number = 999;
  private lastGyroMag: number = 999;
  private accPeak: number = 0;
  private gyroPeak: number = 0;
  private onFallCb: (e: FallEvent) => void = () => {};

  configure(cfg: FallConfig): void {
    this.cfg = cfg;
  }

  onFallDetected(cb: (e: FallEvent) => void): void {
    this.onFallCb = cb;
  }

  processAccel(x: number, y: number, z: number): void {
    const mag = Math.sqrt((x*x) + (y*y) + (z*z));
    this.lastAccMag = mag;

    if(mag > this.cfg.impactThreshold) {
      this.lastImpactTs = Date.now();
      if(mag > this.accPeak) {
        this.accPeak = mag;
      }
    }
    this.check();
  }

  processGyro(x: number, y: number, z: number): void {
    const mag = Math.sqrt((x*x) + (y*y) + (z*z));
    this.lastGyroMag = mag;

    if (mag > this.cfg.gyroThreshold) {
      this.orientationChanged = true;
      if (mag > this.gyroPeak) {
        this.gyroPeak = mag;
      }
    }
    this.check();
  }

  private isImmobile(): boolean {
    return this.lastAccMag < this.cfg.immobileAcc && this.lastGyroMag < this.cfg.immobileGyro;
  }

  private check(): void {
    if(this.lastImpactTs <= 0) {
      return;
    }
    const dt = Date.now() - this.lastImpactTs;
    if(dt < this.cfg.immobileTimeMs) {
      return;
    }

    if(this.orientationChanged && this.isImmobile()) {
      const e: FallEvent = {
        ts: Date.now(),
        accPeak: this.accPeak,
        gyroPeak: this.gyroPeak
      };
      this.onFallCb(e);
      this.reset();
    }
  }

  private reset(): void {
    this.lastImpactTs = 0;
    this.orientationChanged = false;
    this.lastAccMag = 999;
    this.lastGyroMag = 999;
    this.accPeak = 0;
    this.gyroPeak = 0;
  }
}

export const detectionEngine = new DetectionEngine();