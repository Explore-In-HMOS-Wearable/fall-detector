// FallStore.ets
export interface FallEvent {
  ts: number;
  accPeak: number;
  gyroPeak: number;
}

export interface FallConfig {
  impactThreshold: number;     // accel magnitude threshold
  gyroThreshold: number;       // gyro magnitude threshold
  immobileTimeMs: number;
  immobileAcc: number;         // accel magnitude for immobility
  immobileGyro: number;        // gyro magnitude for immobility
}

export interface FallPrefs {
  mockEnabled: boolean;
}

const KEY_PREFS = 'fall_prefs';

const DEFAULT_PREFS: FallPrefs = {
  mockEnabled: true
};

export const DEFAULT_PREFS_JSON: string = JSON.stringify(DEFAULT_PREFS);

const KEY_EVENTS = 'fall_events';
const KEY_CONFIG = 'fall_config';
const DEFAULT_CONFIG: FallConfig = {
  impactThreshold: 22.0,
  gyroThreshold: 4.5,
  immobileTimeMs: 1200,
  immobileAcc: 1.3,
  immobileGyro: 0.6
};

export const DEFAULT_CONFIG_JSON: string = JSON.stringify(DEFAULT_CONFIG);

function safeParseJson<T>(s: string, fallback: T): T {
  try {
    return JSON.parse(s) as T;
  } catch (_) {
    return fallback;
  }
}

interface IFallStore {
  init(): void;
  addEvent(e: FallEvent): void;
  getEvents(): FallEvent[];
  clearEvents(): void;
  getConfig(): FallConfig;
  setConfig(c: FallConfig): void;
  getPrefs(): FallPrefs;
  setPrefs(p: FallPrefs): void;
}

class FallStoreImpl implements IFallStore {
  init(): void {
    AppStorage.setOrCreate(KEY_EVENTS, JSON.stringify([]));
    AppStorage.setOrCreate(KEY_CONFIG, JSON.stringify(DEFAULT_CONFIG));

    const ev: string | undefined = AppStorage.get(KEY_EVENTS) as (string | undefined);
    if(!ev || ev.length === 0) {
      AppStorage.setOrCreate(KEY_EVENTS, JSON.stringify([]));
    }

    const cfg: string | undefined = AppStorage.get(KEY_CONFIG) as (string | undefined);
    if(!cfg || cfg.length === 0) {
      AppStorage.setOrCreate(KEY_CONFIG, DEFAULT_CONFIG_JSON);
    }
  }

  getPrefs(): FallPrefs {
    const raw: string = AppStorage.get(KEY_PREFS) as string;
    return safeParseJson<FallPrefs>(raw, DEFAULT_PREFS);
  }

  setPrefs(p: FallPrefs): void {
    AppStorage.set(KEY_PREFS, JSON.stringify(p));
  }

  addEvent(e: FallEvent): void {
    const raw = AppStorage.get(KEY_EVENTS) as string;
    const list = safeParseJson<FallEvent[]>(raw, []);
    list.unshift(e);
    AppStorage.set(KEY_EVENTS, JSON.stringify(list.slice(0, 50)));
  }

  getEvents(): FallEvent[] {
    const raw = AppStorage.get(KEY_EVENTS) as string;
    return safeParseJson<FallEvent[]>(raw, []);
  }

  clearEvents(): void {
    AppStorage.set(KEY_EVENTS, JSON.stringify([]));
  }

  getConfig(): FallConfig {
    const raw = AppStorage.get(KEY_CONFIG) as string;
    return safeParseJson<FallConfig>(raw, DEFAULT_CONFIG);
  }

  setConfig(c: FallConfig): void {
    AppStorage.set(KEY_CONFIG, JSON.stringify(c));
  }
}

export const fallStore: IFallStore = new FallStoreImpl();