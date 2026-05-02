import { relationalStore, preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export interface FallEvent {
  id?: number;
  ts: number;
  accPeak: number;
  gyroPeak: number;
}

export interface FallConfig {
  impactThreshold: number;
  gyroThreshold: number;
  immobileTimeMs: number;
  immobileAcc: number;
  immobileGyro: number;
}

export interface FallPrefs {
  mockEnabled: boolean;
}

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'FallDetector.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const TABLE_NAME = 'fall_events';
const CREATE_TABLE_SQL = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts INTEGER NOT NULL,
  accPeak REAL NOT NULL,
  gyroPeak REAL NOT NULL
)`;

const PREFS_NAME = 'fall_prefs';
const DEFAULT_CONFIG: FallConfig = {
  impactThreshold: 22.0,
  gyroThreshold: 4.5,
  immobileTimeMs: 1200,
  immobileAcc: 1.3,
  immobileGyro: 0.6
};

class FallStore {
  private rdbStore: relationalStore.RdbStore | null = null;
  private prefs: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await this.rdbStore.executeSql(CREATE_TABLE_SQL);
      this.prefs = await preferences.getPreferences(context, PREFS_NAME);
    } catch (err) {
      console.error(`FallStore init failed: ${JSON.stringify(err)}`);
    }
  }

  async addEvent(e: FallEvent): Promise<void> {
    if (!this.rdbStore) {
      return;
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'ts': e.ts,
      'accPeak': e.accPeak,
      'gyroPeak': e.gyroPeak
    };
    await this.rdbStore.insert(TABLE_NAME, valueBucket);
  }

  async getEvents(): Promise<FallEvent[]> {
    if (!this.rdbStore) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.orderByDesc('ts');
    const resultSet = await this.rdbStore.query(predicates);
    const result: FallEvent[] = [];
    while (resultSet.goToNextRow()) {
      result.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        ts: resultSet.getLong(resultSet.getColumnIndex('ts')),
        accPeak: resultSet.getDouble(resultSet.getColumnIndex('accPeak')),
        gyroPeak: resultSet.getDouble(resultSet.getColumnIndex('gyroPeak'))
      });
    }
    resultSet.close();
    return result;
  }

  async clearEvents(): Promise<void> {
    if (!this.rdbStore) {
      return;
    }
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    await this.rdbStore.delete(predicates);
  }

  async getConfig(): Promise<FallConfig> {
    if (!this.prefs) {
      return DEFAULT_CONFIG;
    }
    const raw = await this.prefs.get('config', JSON.stringify(DEFAULT_CONFIG)) as string;
    try {
      return JSON.parse(raw) as FallConfig;
    } catch (_) {
      return DEFAULT_CONFIG;
    }
  }

  async setConfig(c: FallConfig): Promise<void> {
    if (!this.prefs) {
      return;
    }
    await this.prefs.put('config', JSON.stringify(c));
    await this.prefs.flush();
  }

  async getPrefs(): Promise<FallPrefs> {
    if (!this.prefs) {
      return { mockEnabled: true };
    }
    const mock = await this.prefs.get('mockEnabled', true) as boolean;
    return { mockEnabled: mock };
  }

  async setPrefs(p: FallPrefs): Promise<void> {
    if (!this.prefs) {
      return;
    }
    await this.prefs.put('mockEnabled', p.mockEnabled);
    await this.prefs.flush();
  }
}

export const fallStore = new FallStore();
