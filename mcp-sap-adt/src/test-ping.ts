import dotenv from 'dotenv';
import path from 'path';
import { SapAdtClient } from './sap-adt-client';
import { SapConnectionConfig } from './types';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const config: SapConnectionConfig = {
  url: process.env.SAP_URL || '',
  client: process.env.SAP_CLIENT || '100',
  username: process.env.SAP_USER || '',
  password: process.env.SAP_PASSWORD || '',
  language: process.env.SAP_LANGUAGE || 'EN',
  allowSelfSigned: process.env.SAP_ALLOW_SELF_SIGNED === 'true',
};

async function testConnection() {
  console.log('Testing SAP ADT Connection...');
  console.log(`Endpoint: ${config.url}`);
  console.log(`Client:   ${config.client}`);
  console.log(`User:     ${config.username}`);

  if (!config.password) {
    console.warn('\n⚠️ Note: SAP_PASSWORD is empty in .env. Attempting ping without auth token...');
  }

  const client = new SapAdtClient(config);
  const result = await client.ping();
  console.log('\nPing Result:');
  console.log(JSON.stringify(result, null, 2));
}

testConnection().catch((err) => {
  console.error('Test execution failed:', err);
});
