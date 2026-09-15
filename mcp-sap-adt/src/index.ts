#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import dotenv from 'dotenv';
import path from 'path';
import { SapAdtClient } from './sap-adt-client';
import { SapConnectionConfig } from './types';

// Load .env from project root or current folder
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const config: SapConnectionConfig = {
  url: process.env.SAP_URL || 'https://a4796127-12c7-4a21-ae82-e3ced4ab9c3d.abap.us10.hana.ondemand.com',
  client: process.env.SAP_CLIENT || '100',
  username: process.env.SAP_USER || 'BPT_TRIAL',
  password: process.env.SAP_PASSWORD || '',
  language: process.env.SAP_LANGUAGE || 'EN',
  allowSelfSigned: process.env.SAP_ALLOW_SELF_SIGNED === 'true',
};

const adtClient = new SapAdtClient(config);

const server = new Server(
  {
    name: 'sap-adt-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

/**
 * List available SAP ADT tools
 */
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'sap_ping',
        description: 'Check connectivity to the SAP ADT backend service and verify CSRF token handshake.',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'sap_read_class',
        description: 'Read ABAP class source code and its includes (definitions, implementations, testclasses) directly from SAP DEV.',
        inputSchema: {
          type: 'object',
          properties: {
            className: {
              type: 'string',
              description: 'The name of the ABAP class (e.g., ZCL_HELLO_BTP).',
            },
          },
          required: ['className'],
        },
      },
      {
        name: 'sap_check_syntax',
        description: 'Perform real-time compiler syntax checking on ABAP class source code against SAP DEV without saving dirty state.',
        inputSchema: {
          type: 'object',
          properties: {
            className: {
              type: 'string',
              description: 'The name of the ABAP class (e.g., ZCL_HELLO_BTP).',
            },
            source: {
              type: 'string',
              description: 'The ABAP source code to validate.',
            },
          },
          required: ['className', 'source'],
        },
      },
      {
        name: 'sap_write_class',
        description: 'Lock an ABAP class via stateful session, write the modified source to the inactive version on SAP DEV, and unlock it.',
        inputSchema: {
          type: 'object',
          properties: {
            className: {
              type: 'string',
              description: 'The name of the ABAP class to modify.',
            },
            source: {
              type: 'string',
              description: 'The updated ABAP source code.',
            },
          },
          required: ['className', 'source'],
        },
      },
      {
        name: 'sap_activate_class',
        description: 'Activate an inactive ABAP class in the SAP Data Dictionary.',
        inputSchema: {
          type: 'object',
          properties: {
            className: {
              type: 'string',
              description: 'The name of the ABAP class to activate.',
            },
          },
          required: ['className'],
        },
      },
      {
        name: 'sap_run_unit_tests',
        description: 'Execute ABAP Unit tests for a specific class on SAP DEV and return structured pass/fail results.',
        inputSchema: {
          type: 'object',
          properties: {
            className: {
              type: 'string',
              description: 'The name of the ABAP class to test (e.g., ZCL_HELLO_BTP_TEST).',
            },
          },
          required: ['className'],
        },
      },
    ],
  };
});

/**
 * Handle execution of SAP ADT tools
 */
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'sap_ping': {
        const pingResult = await adtClient.ping();
        return {
          content: [{ type: 'text', text: JSON.stringify(pingResult, null, 2) }],
        };
      }

      case 'sap_read_class': {
        const className = String(args?.className || '');
        if (!className) throw new Error('className argument is required.');
        const sourceData = await adtClient.readClass(className);
        return {
          content: [{ type: 'text', text: JSON.stringify(sourceData, null, 2) }],
        };
      }

      case 'sap_check_syntax': {
        const className = String(args?.className || '');
        const source = String(args?.source || '');
        if (!className || !source) throw new Error('className and source are required.');
        const checkResult = await adtClient.checkSyntax(className, source);
        return {
          content: [{ type: 'text', text: JSON.stringify(checkResult, null, 2) }],
        };
      }

      case 'sap_write_class': {
        const className = String(args?.className || '');
        const source = String(args?.source || '');
        if (!className || !source) throw new Error('className and source are required.');
        const writeResult = await adtClient.writeClassSource(className, source);
        return {
          content: [{ type: 'text', text: JSON.stringify(writeResult, null, 2) }],
        };
      }

      case 'sap_activate_class': {
        const className = String(args?.className || '');
        if (!className) throw new Error('className argument is required.');
        const actResult = await adtClient.activateClass(className);
        return {
          content: [{ type: 'text', text: JSON.stringify(actResult, null, 2) }],
        };
      }

      case 'sap_run_unit_tests': {
        const className = String(args?.className || '');
        if (!className) throw new Error('className argument is required.');
        const testResult = await adtClient.runUnitTests(className);
        return {
          content: [{ type: 'text', text: JSON.stringify(testResult, null, 2) }],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error: any) {
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(
            {
              error: true,
              tool: name,
              message: error.message || String(error),
            },
            null,
            2
          ),
        },
      ],
      isError: true,
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('SAP ADT MCP Server running on stdio');
}

main().catch((err) => {
  console.error('Fatal MCP Server error:', err);
  process.exit(1);
});
