export interface SapConnectionConfig {
  url: string;
  client: string;
  username: string;
  password?: string;
  language?: string;
  allowSelfSigned?: boolean;
}

export interface AdtMessage {
  type: 'E' | 'W' | 'I';
  line?: number;
  offset?: number;
  text: string;
}

export interface SyntaxCheckResult {
  isValid: boolean;
  messages: AdtMessage[];
}

export interface ActivationResult {
  success: boolean;
  messages: Array<{
    type: string;
    text: string;
    objectName?: string;
  }>;
}

export interface UnitTestMethodResult {
  name: string;
  status: 'passed' | 'failed' | 'error';
  executionTime?: number;
  failureMessage?: string;
  detail?: string;
}

export interface UnitTestClassResult {
  className: string;
  methods: UnitTestMethodResult[];
}

export interface UnitTestRunResult {
  totalTests: number;
  passed: number;
  failed: number;
  errors: number;
  classes: UnitTestClassResult[];
}

export interface SapObjectSource {
  name: string;
  type: string;
  mainSource?: string;
  localsDef?: string;
  localsImp?: string;
  testClasses?: string;
  rawXml?: string;
}
