# Time-Series Databases Expert (InfluxDB & TimescaleDB)

> **Version:** 2.0.0 | **Updated:** 2026-02-01  
> **InfluxDB:** 2.x/3.x  
> **TimescaleDB:** 2.x  
> **Priority:** P0 - Load for IoT/metrics projects

---

You are an expert in Time-Series Databases (TSDB) like InfluxDB and TimescaleDB.

## Core Principles

- Optimize for high write throughput
- Efficient compression is critical
- Downsampling for long-term storage
- Handle high cardinality carefully

---

## 1) InfluxDB

### Line Protocol
```plaintext
# ==========================================
# LINE PROTOCOL FORMAT
# ==========================================

# Format: measurement,tag1=value1,tag2=value2 field1=value1,field2=value2 timestamp

# Basic example
temperature,location=office,sensor=temp01 value=23.5 1705312800000000000

# Multiple fields
weather,location=nyc temperature=72.5,humidity=65.2,pressure=1013.25 1705312800000000000

# Multiple tags (indexed for filtering)
cpu,host=server01,region=us-east,datacenter=dc1 usage_user=25.5,usage_system=10.2 1705312800000000000

# String field (must be quoted)
events,source=api message="User logged in",level="info" 1705312800000000000

# Boolean field
system,host=server01 active=true,maintenance=false 1705312800000000000


# ==========================================
# BATCH WRITE EXAMPLE
# ==========================================

# Send multiple points in one request
temperature,location=office,sensor=temp01 value=23.5 1705312800000000000
temperature,location=office,sensor=temp02 value=24.1 1705312800000000000
temperature,location=warehouse,sensor=temp03 value=18.2 1705312800000000000
humidity,location=office value=65.2 1705312800000000000
humidity,location=warehouse value=72.1 1705312800000000000
```

### Flux Query Language
```javascript
// ==========================================
// BASIC QUERIES
// ==========================================

// Query last hour of temperature data
from(bucket: "sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> filter(fn: (r) => r.location == "office")

// Query with specific time range
from(bucket: "sensors")
  |> range(start: 2024-01-15T00:00:00Z, stop: 2024-01-16T00:00:00Z)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> filter(fn: (r) => r._field == "usage_user")


// ==========================================
// AGGREGATIONS
// ==========================================

// Average temperature per hour
from(bucket: "sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)

// Multiple aggregations
from(bucket: "sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 1h, fn: mean)
  |> yield(name: "mean")

from(bucket: "sensors")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 1h, fn: max)
  |> yield(name: "max")

// Percentiles
from(bucket: "sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "response_time")
  |> aggregateWindow(every: 5m, fn: (column, tables=<-) =>
      tables |> quantile(q: 0.95, column: column))


// ==========================================
// DOWNSAMPLING
// ==========================================

// Downsample from 1-minute to 1-hour data
from(bucket: "sensors")
  |> range(start: -7d)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 1h, fn: mean)
  |> to(bucket: "sensors_hourly")


// ==========================================
// GAP FILLING
// ==========================================

// Fill missing data points with previous value
from(bucket: "sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 1m, fn: last, createEmpty: true)
  |> fill(usePrevious: true)

// Fill with specific value
from(bucket: "sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 1m, fn: last, createEmpty: true)
  |> fill(value: 0.0)


// ==========================================
// JOINS AND CALCULATIONS
// ==========================================

// Calculate rate of change
from(bucket: "sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "counter")
  |> derivative(unit: 1s, nonNegative: true)

// Join two measurements
cpu = from(bucket: "metrics")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> filter(fn: (r) => r._field == "usage")

memory = from(bucket: "metrics")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "memory")
  |> filter(fn: (r) => r._field == "used_percent")

join(tables: {cpu: cpu, memory: memory}, on: ["_time", "host"])
  |> map(fn: (r) => ({
      _time: r._time,
      host: r.host,
      cpu_usage: r._value_cpu,
      memory_usage: r._value_memory
  }))


// ==========================================
// ALERTING WITH CHECKS
// ==========================================

// Check for high CPU usage
from(bucket: "metrics")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> filter(fn: (r) => r._field == "usage_user")
  |> aggregateWindow(every: 1m, fn: mean)
  |> map(fn: (r) => ({r with 
      level: if r._value > 90.0 then "critical"
             else if r._value > 75.0 then "warning"
             else "ok"
  }))
```

### InfluxDB Tasks
```javascript
// ==========================================
// BACKGROUND TASK FOR DOWNSAMPLING
// ==========================================

option task = {
  name: "Downsample temperature data",
  every: 1h,
  offset: 5m
}

from(bucket: "sensors_raw")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._measurement == "temperature")
  |> aggregateWindow(every: 1h, fn: mean)
  |> to(bucket: "sensors_hourly", org: "myorg")


// ==========================================
// TASK WITH MULTIPLE AGGREGATIONS
// ==========================================

option task = {
  name: "Calculate hourly statistics",
  every: 1h
}

data = from(bucket: "sensors")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "temperature")

// Mean
data
  |> aggregateWindow(every: 1h, fn: mean)
  |> set(key: "_field", value: "mean")
  |> to(bucket: "sensors_stats")

// Max
data
  |> aggregateWindow(every: 1h, fn: max)
  |> set(key: "_field", value: "max")
  |> to(bucket: "sensors_stats")

// Min
data
  |> aggregateWindow(every: 1h, fn: min)
  |> set(key: "_field", value: "min")
  |> to(bucket: "sensors_stats")
```

---

## 2) TimescaleDB

### Hypertable Setup
```sql
-- ==========================================
-- CREATE HYPERTABLE
-- ==========================================

-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create regular table first
CREATE TABLE sensor_data (
    time        TIMESTAMPTZ NOT NULL,
    sensor_id   INTEGER NOT NULL,
    location    TEXT NOT NULL,
    temperature DOUBLE PRECISION,
    humidity    DOUBLE PRECISION,
    pressure    DOUBLE PRECISION
);

-- Convert to hypertable (auto-partitioned by time)
SELECT create_hypertable('sensor_data', 'time');

-- With specific chunk interval (default is 7 days)
SELECT create_hypertable(
    'sensor_data', 
    'time',
    chunk_time_interval => INTERVAL '1 day'
);

-- Create indexes (TimescaleDB optimizes these)
CREATE INDEX idx_sensor_data_sensor ON sensor_data (sensor_id, time DESC);
CREATE INDEX idx_sensor_data_location ON sensor_data (location, time DESC);


-- ==========================================
-- MULTI-DIMENSIONAL PARTITIONING
-- ==========================================

-- Partition by time AND sensor_id (for high cardinality)
SELECT create_hypertable(
    'sensor_data',
    'time',
    partitioning_column => 'sensor_id',
    number_partitions => 4
);


-- ==========================================
-- METRICS TABLE EXAMPLE
-- ==========================================

CREATE TABLE metrics (
    time        TIMESTAMPTZ NOT NULL,
    host        TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    value       DOUBLE PRECISION NOT NULL,
    tags        JSONB DEFAULT '{}'
);

SELECT create_hypertable('metrics', 'time');

-- Composite index for common queries
CREATE INDEX idx_metrics_host_metric ON metrics (host, metric_name, time DESC);

-- GIN index for JSONB tags
CREATE INDEX idx_metrics_tags ON metrics USING GIN (tags);


-- ==========================================
-- IoT DEVICE DATA
-- ==========================================

CREATE TABLE device_telemetry (
    time            TIMESTAMPTZ NOT NULL,
    device_id       UUID NOT NULL,
    device_type     TEXT NOT NULL,
    battery_level   SMALLINT,
    signal_strength INTEGER,
    latitude        DOUBLE PRECISION,
    longitude       DOUBLE PRECISION,
    payload         JSONB
);

SELECT create_hypertable('device_telemetry', 'time');

CREATE INDEX idx_device_telemetry_device ON device_telemetry (device_id, time DESC);
CREATE INDEX idx_device_telemetry_type ON device_telemetry (device_type, time DESC);
```

### Time-Series Queries
```sql
-- ==========================================
-- BASIC TIME-SERIES QUERIES
-- ==========================================

-- Last hour of data
SELECT time, sensor_id, temperature, humidity
FROM sensor_data
WHERE time > NOW() - INTERVAL '1 hour'
ORDER BY time DESC;

-- Specific time range
SELECT *
FROM sensor_data
WHERE time BETWEEN '2024-01-15 00:00:00' AND '2024-01-16 00:00:00'
  AND sensor_id = 1
ORDER BY time;


-- ==========================================
-- TIME BUCKETING (Aggregations)
-- ==========================================

-- Average per hour
SELECT 
    time_bucket('1 hour', time) AS bucket,
    sensor_id,
    AVG(temperature) AS avg_temp,
    MAX(temperature) AS max_temp,
    MIN(temperature) AS min_temp,
    COUNT(*) AS readings
FROM sensor_data
WHERE time > NOW() - INTERVAL '24 hours'
GROUP BY bucket, sensor_id
ORDER BY bucket DESC;

-- Custom bucket sizes
SELECT 
    time_bucket('15 minutes', time) AS bucket,
    location,
    AVG(temperature) AS avg_temp
FROM sensor_data
WHERE time > NOW() - INTERVAL '6 hours'
GROUP BY bucket, location
ORDER BY bucket, location;

-- With gap filling
SELECT 
    time_bucket_gapfill('1 hour', time) AS bucket,
    sensor_id,
    AVG(temperature) AS avg_temp,
    locf(AVG(temperature)) AS avg_temp_filled  -- Last observation carried forward
FROM sensor_data
WHERE time > NOW() - INTERVAL '24 hours'
  AND sensor_id = 1
GROUP BY bucket, sensor_id
ORDER BY bucket;


-- ==========================================
-- WINDOW FUNCTIONS
-- ==========================================

-- Rate of change
SELECT 
    time,
    sensor_id,
    temperature,
    temperature - LAG(temperature) OVER (
        PARTITION BY sensor_id ORDER BY time
    ) AS temp_change,
    time - LAG(time) OVER (
        PARTITION BY sensor_id ORDER BY time
    ) AS time_delta
FROM sensor_data
WHERE time > NOW() - INTERVAL '1 hour'
ORDER BY sensor_id, time;

-- Moving average
SELECT 
    time,
    sensor_id,
    temperature,
    AVG(temperature) OVER (
        PARTITION BY sensor_id 
        ORDER BY time 
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ) AS moving_avg_6
FROM sensor_data
WHERE time > NOW() - INTERVAL '1 hour';

-- Percentiles
SELECT 
    time_bucket('1 hour', time) AS bucket,
    percentile_cont(0.50) WITHIN GROUP (ORDER BY temperature) AS median,
    percentile_cont(0.95) WITHIN GROUP (ORDER BY temperature) AS p95,
    percentile_cont(0.99) WITHIN GROUP (ORDER BY temperature) AS p99
FROM sensor_data
WHERE time > NOW() - INTERVAL '24 hours'
GROUP BY bucket
ORDER BY bucket;


-- ==========================================
-- ADVANCED ANALYTICS
-- ==========================================

-- First/Last value per bucket
SELECT 
    time_bucket('1 hour', time) AS bucket,
    sensor_id,
    first(temperature, time) AS first_temp,
    last(temperature, time) AS last_temp,
    last(temperature, time) - first(temperature, time) AS temp_change
FROM sensor_data
WHERE time > NOW() - INTERVAL '24 hours'
GROUP BY bucket, sensor_id;

-- Histogram
SELECT 
    time_bucket('1 day', time) AS bucket,
    histogram(temperature, 0, 50, 10) AS temp_distribution
FROM sensor_data
WHERE time > NOW() - INTERVAL '7 days'
GROUP BY bucket;

-- Interpolation
SELECT 
    time,
    interpolate(AVG(temperature)) AS temp_interpolated
FROM sensor_data
WHERE time > NOW() - INTERVAL '24 hours'
GROUP BY time_bucket_gapfill('5 minutes', time), time
ORDER BY time;
```

### Continuous Aggregates
```sql
-- ==========================================
-- CREATE CONTINUOUS AGGREGATE
-- ==========================================

-- Hourly statistics (auto-refreshed materialized view)
CREATE MATERIALIZED VIEW sensor_hourly
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 hour', time) AS bucket,
    sensor_id,
    location,
    AVG(temperature) AS avg_temp,
    MAX(temperature) AS max_temp,
    MIN(temperature) AS min_temp,
    AVG(humidity) AS avg_humidity,
    COUNT(*) AS readings
FROM sensor_data
GROUP BY bucket, sensor_id, location
WITH NO DATA;

-- Refresh policy (auto-refresh every hour)
SELECT add_continuous_aggregate_policy('sensor_hourly',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);

-- Manual refresh
CALL refresh_continuous_aggregate('sensor_hourly', NULL, NULL);


-- ==========================================
-- DAILY AGGREGATE FROM HOURLY
-- ==========================================

CREATE MATERIALIZED VIEW sensor_daily
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 day', bucket) AS day,
    sensor_id,
    location,
    AVG(avg_temp) AS avg_temp,
    MAX(max_temp) AS max_temp,
    MIN(min_temp) AS min_temp,
    SUM(readings) AS total_readings
FROM sensor_hourly
GROUP BY day, sensor_id, location
WITH NO DATA;

SELECT add_continuous_aggregate_policy('sensor_daily',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);


-- ==========================================
-- QUERY CONTINUOUS AGGREGATES
-- ==========================================

-- Query like a regular view (very fast!)
SELECT *
FROM sensor_hourly
WHERE bucket > NOW() - INTERVAL '7 days'
  AND sensor_id = 1
ORDER BY bucket DESC;

-- Combine raw and aggregated for different time ranges
SELECT bucket AS time, avg_temp, 'hourly' AS resolution
FROM sensor_hourly
WHERE bucket > NOW() - INTERVAL '7 days' AND sensor_id = 1
UNION ALL
SELECT day AS time, avg_temp, 'daily' AS resolution
FROM sensor_daily
WHERE day <= NOW() - INTERVAL '7 days' AND sensor_id = 1
ORDER BY time DESC;
```

### Retention & Compression
```sql
-- ==========================================
-- DATA RETENTION POLICIES
-- ==========================================

-- Auto-drop chunks older than 30 days
SELECT add_retention_policy('sensor_data', INTERVAL '30 days');

-- View retention policies
SELECT * FROM timescaledb_information.jobs
WHERE proc_name = 'policy_retention';

-- Drop policy
SELECT remove_retention_policy('sensor_data');


-- ==========================================
-- COMPRESSION
-- ==========================================

-- Enable compression on hypertable
ALTER TABLE sensor_data SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'sensor_id',
    timescaledb.compress_orderby = 'time DESC'
);

-- Compression policy (compress chunks older than 7 days)
SELECT add_compression_policy('sensor_data', INTERVAL '7 days');

-- Manual compression
SELECT compress_chunk(chunk) 
FROM show_chunks('sensor_data', older_than => INTERVAL '7 days') AS chunk;

-- Check compression stats
SELECT 
    hypertable_name,
    chunk_name,
    before_compression_total_bytes,
    after_compression_total_bytes,
    (1 - after_compression_total_bytes::float / before_compression_total_bytes) * 100 AS compression_ratio
FROM timescaledb_information.compressed_chunk_stats;

-- Decompress for updates (if needed)
SELECT decompress_chunk('_timescaledb_internal._hyper_1_1_chunk');


-- ==========================================
-- TIERED STORAGE (Hot/Warm/Cold)
-- ==========================================

-- Move old data to cheaper storage (TimescaleDB 2.13+)
SELECT add_tiered_storage_policy('sensor_data',
    INTERVAL '30 days',  -- Move chunks older than 30 days
    target_tablespace => 'cold_storage'
);
```

---

## 3) TypeScript Integration

### InfluxDB Client
```typescript
// ==========================================
// INFLUXDB CLIENT
// ==========================================

import { InfluxDB, Point, WriteApi, QueryApi } from '@influxdata/influxdb-client';

const influxDB = new InfluxDB({
  url: process.env.INFLUXDB_URL!,
  token: process.env.INFLUXDB_TOKEN!,
});

const org = process.env.INFLUXDB_ORG!;
const bucket = process.env.INFLUXDB_BUCKET!;

// Write API with batching
const writeApi: WriteApi = influxDB.getWriteApi(org, bucket, 'ms', {
  batchSize: 1000,
  flushInterval: 1000,
  maxRetries: 3,
});

// Write single point
async function writeSensorData(
  sensorId: string,
  location: string,
  temperature: number,
  humidity: number
): Promise<void> {
  const point = new Point('sensor_data')
    .tag('sensor_id', sensorId)
    .tag('location', location)
    .floatField('temperature', temperature)
    .floatField('humidity', humidity)
    .timestamp(new Date());

  writeApi.writePoint(point);
}

// Batch write
async function writeBatch(readings: SensorReading[]): Promise<void> {
  for (const reading of readings) {
    const point = new Point('sensor_data')
      .tag('sensor_id', reading.sensorId)
      .tag('location', reading.location)
      .floatField('temperature', reading.temperature)
      .floatField('humidity', reading.humidity)
      .timestamp(reading.timestamp);

    writeApi.writePoint(point);
  }

  await writeApi.flush();
}

// Query API
const queryApi: QueryApi = influxDB.getQueryApi(org);

interface SensorDataRow {
  _time: string;
  sensor_id: string;
  location: string;
  _value: number;
  _field: string;
}

async function getHourlyAverages(
  sensorId: string,
  hours: number = 24
): Promise<SensorDataRow[]> {
  const query = `
    from(bucket: "${bucket}")
      |> range(start: -${hours}h)
      |> filter(fn: (r) => r._measurement == "sensor_data")
      |> filter(fn: (r) => r.sensor_id == "${sensorId}")
      |> filter(fn: (r) => r._field == "temperature")
      |> aggregateWindow(every: 1h, fn: mean)
  `;

  const results: SensorDataRow[] = [];

  for await (const { values, tableMeta } of queryApi.iterateRows(query)) {
    const row = tableMeta.toObject(values) as SensorDataRow;
    results.push(row);
  }

  return results;
}

// Cleanup
process.on('exit', () => {
  writeApi.close();
});
```

### TimescaleDB Client
```typescript
// ==========================================
// TIMESCALEDB CLIENT (PostgreSQL)
// ==========================================

import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.TIMESCALEDB_URL,
  max: 20,
  idleTimeoutMillis: 30000,
});

interface SensorReading {
  time: Date;
  sensorId: number;
  location: string;
  temperature: number;
  humidity: number;
}

// Batch insert with COPY
async function insertBatch(readings: SensorReading[]): Promise<void> {
  const client = await pool.connect();
  
  try {
    // Use COPY for high performance
    const copyQuery = `
      COPY sensor_data (time, sensor_id, location, temperature, humidity)
      FROM STDIN WITH (FORMAT csv)
    `;
    
    const stream = client.query(copyQuery);
    
    for (const reading of readings) {
      const row = [
        reading.time.toISOString(),
        reading.sensorId,
        reading.location,
        reading.temperature,
        reading.humidity,
      ].join(',') + '\n';
      
      stream.write(row);
    }
    
    await stream.end();
  } finally {
    client.release();
  }
}

// Alternative: Bulk INSERT
async function insertBulk(readings: SensorReading[]): Promise<void> {
  const values = readings.map((r, i) => {
    const offset = i * 5;
    return `($${offset + 1}, $${offset + 2}, $${offset + 3}, $${offset + 4}, $${offset + 5})`;
  }).join(',');

  const params = readings.flatMap(r => [
    r.time,
    r.sensorId,
    r.location,
    r.temperature,
    r.humidity,
  ]);

  await pool.query(`
    INSERT INTO sensor_data (time, sensor_id, location, temperature, humidity)
    VALUES ${values}
  `, params);
}

// Query with time bucketing
async function getHourlyStats(
  sensorId: number,
  startTime: Date,
  endTime: Date
): Promise<HourlyStat[]> {
  const result = await pool.query<HourlyStat>(`
    SELECT 
      time_bucket('1 hour', time) AS bucket,
      AVG(temperature) AS avg_temp,
      MAX(temperature) AS max_temp,
      MIN(temperature) AS min_temp,
      COUNT(*) AS readings
    FROM sensor_data
    WHERE sensor_id = $1
      AND time BETWEEN $2 AND $3
    GROUP BY bucket
    ORDER BY bucket DESC
  `, [sensorId, startTime, endTime]);

  return result.rows;
}

// Query continuous aggregate
async function getDailyStats(
  sensorId: number,
  days: number = 30
): Promise<DailyStat[]> {
  const result = await pool.query<DailyStat>(`
    SELECT 
      bucket,
      avg_temp,
      max_temp,
      min_temp,
      total_readings
    FROM sensor_daily
    WHERE sensor_id = $1
      AND bucket > NOW() - INTERVAL '${days} days'
    ORDER BY bucket DESC
  `, [sensorId]);

  return result.rows;
}


// ==========================================
// TYPED REPOSITORY
// ==========================================

interface TimeSeriesRepository<T> {
  insert(data: T): Promise<void>;
  insertBatch(data: T[]): Promise<void>;
  query(start: Date, end: Date, filters?: Record<string, unknown>): Promise<T[]>;
  aggregate(bucket: string, start: Date, end: Date): Promise<AggregatedData[]>;
}

class SensorRepository implements TimeSeriesRepository<SensorReading> {
  constructor(private pool: Pool) {}

  async insert(data: SensorReading): Promise<void> {
    await this.pool.query(`
      INSERT INTO sensor_data (time, sensor_id, location, temperature, humidity)
      VALUES ($1, $2, $3, $4, $5)
    `, [data.time, data.sensorId, data.location, data.temperature, data.humidity]);
  }

  async insertBatch(data: SensorReading[]): Promise<void> {
    if (data.length === 0) return;

    const values = data.map((_, i) => {
      const o = i * 5;
      return `($${o+1}, $${o+2}, $${o+3}, $${o+4}, $${o+5})`;
    }).join(',');

    const params = data.flatMap(d => [
      d.time, d.sensorId, d.location, d.temperature, d.humidity
    ]);

    await this.pool.query(`
      INSERT INTO sensor_data (time, sensor_id, location, temperature, humidity)
      VALUES ${values}
    `, params);
  }

  async query(
    start: Date,
    end: Date,
    filters?: { sensorId?: number; location?: string }
  ): Promise<SensorReading[]> {
    let query = `
      SELECT time, sensor_id, location, temperature, humidity
      FROM sensor_data
      WHERE time BETWEEN $1 AND $2
    `;
    const params: unknown[] = [start, end];

    if (filters?.sensorId) {
      params.push(filters.sensorId);
      query += ` AND sensor_id = $${params.length}`;
    }

    if (filters?.location) {
      params.push(filters.location);
      query += ` AND location = $${params.length}`;
    }

    query += ' ORDER BY time DESC';

    const result = await this.pool.query(query, params);
    return result.rows;
  }

  async aggregate(
    bucket: string,
    start: Date,
    end: Date
  ): Promise<AggregatedData[]> {
    const result = await this.pool.query(`
      SELECT 
        time_bucket($1, time) AS bucket,
        sensor_id,
        AVG(temperature) AS avg_temp,
        MAX(temperature) AS max_temp,
        MIN(temperature) AS min_temp
      FROM sensor_data
      WHERE time BETWEEN $2 AND $3
      GROUP BY bucket, sensor_id
      ORDER BY bucket DESC
    `, [bucket, start, end]);

    return result.rows;
  }
}
```

---

## 4) Data Modeling Best Practices

### Choosing Tags vs Fields
```plaintext
# ==========================================
# INFLUXDB: TAGS VS FIELDS
# ==========================================

# TAGS (Indexed - for filtering/grouping)
# ✅ Use for:
- Fixed set of values (location, sensor_id, region)
- Values you filter on frequently
- Values you GROUP BY

# ❌ Avoid high cardinality tags:
- User IDs (millions of unique values)
- Request IDs / Transaction IDs
- Timestamps as tags

# EXAMPLE - Good tag choices:
sensor_data,location=nyc,building=hq,floor=3,sensor_type=temperature value=23.5

# FIELDS (Not indexed - for measurements)
# ✅ Use for:
- Actual metric values
- High cardinality data
- Data you aggregate (mean, sum, count)

# EXAMPLE - Good field choices:
sensor_data,sensor_id=temp01 temperature=23.5,humidity=65.2,battery=98


# ==========================================
# TIMESCALEDB: COLUMN TYPES
# ==========================================

# Indexed columns (for filtering):
- time (required, always indexed)
- sensor_id, device_id (foreign keys)
- category, type, status (enums)

# Non-indexed columns (measurements):
- temperature, humidity, pressure
- count, sum, rate
- payload (JSONB for flexible data)

# Compound indexes for common queries:
CREATE INDEX ON sensor_data (sensor_id, time DESC);
CREATE INDEX ON sensor_data (location, time DESC) WHERE location IS NOT NULL;
```

### Retention Tiers
```sql
-- ==========================================
-- HOT / WARM / COLD TIERING
-- ==========================================

-- HOT: Raw data (7 days, fast SSD)
-- WARM: Hourly aggregates (90 days, standard storage)
-- COLD: Daily aggregates (years, cheap storage)

-- TimescaleDB implementation:

-- Raw data with 7-day retention
SELECT add_retention_policy('sensor_data', INTERVAL '7 days');

-- Hourly aggregates with 90-day retention
SELECT add_retention_policy('sensor_hourly', INTERVAL '90 days');

-- Daily aggregates with 3-year retention
SELECT add_retention_policy('sensor_daily', INTERVAL '3 years');

-- Compression for warm/cold data
ALTER TABLE sensor_hourly SET (timescaledb.compress);
SELECT add_compression_policy('sensor_hourly', INTERVAL '7 days');

ALTER TABLE sensor_daily SET (timescaledb.compress);
SELECT add_compression_policy('sensor_daily', INTERVAL '30 days');
```

---

## Best Practices Checklist

### Data Modeling
- [ ] Choose tags wisely (low cardinality)
- [ ] Use appropriate timestamp precision
- [ ] Plan retention tiers
- [ ] Design for query patterns

### Ingestion
- [ ] Batch writes (1000+ points)
- [ ] Use NTP for time sync
- [ ] Handle out-of-order data
- [ ] Monitor ingestion rate

### Queries
- [ ] Use time-based filters first
- [ ] Leverage aggregation functions
- [ ] Create continuous aggregates
- [ ] Use indexes appropriately

### Operations
- [ ] Set up retention policies
- [ ] Enable compression
- [ ] Monitor disk usage
- [ ] Plan for downsampling

---

**References:**
- [InfluxDB Documentation](https://docs.influxdata.com/)
- [TimescaleDB Documentation](https://docs.timescale.com/)
- [Time-Series Best Practices](https://www.timescale.com/blog/time-series-data-best-practices/)
