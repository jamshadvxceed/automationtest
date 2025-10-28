#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import { FlutterAnalyzer } from "./flutter-analyzer.js";
import { TestGenerator } from "./test-generator.js";

class FlutterTestGeneratorServer {
  private server: Server;
  private analyzer: FlutterAnalyzer;
  private generator: TestGenerator;

  constructor() {
    this.server = new Server(
      {
        name: "mcp-flutter-test-generator",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.analyzer = new FlutterAnalyzer();
    this.generator = new TestGenerator();
    this.setupHandlers();
  }

  private setupHandlers(): void {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: this.getTools(),
    }));

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "analyze_flutter_app":
            return await this.handleAnalyzeApp(args);
          
          case "generate_test":
            return await this.handleGenerateTest(args);
          
          case "generate_test_suite":
            return await this.handleGenerateTestSuite(args);
          
          case "analyze_widget":
            return await this.handleAnalyzeWidget(args);

          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error: any) {
        return {
          content: [
            {
              type: "text",
              text: `Error: ${error.message}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  private getTools(): Tool[] {
    return [
      {
        name: "analyze_flutter_app",
        description: "Analyze Flutter app structure to identify screens, widgets, and navigation flows",
        inputSchema: {
          type: "object",
          properties: {
            projectPath: {
              type: "string",
              description: "Path to Flutter project root directory",
            },
          },
          required: ["projectPath"],
        },
      },
      {
        name: "generate_test",
        description: "Generate a Patrol integration test for a specific screen or feature",
        inputSchema: {
          type: "object",
          properties: {
            projectPath: {
              type: "string",
              description: "Path to Flutter project",
            },
            screenName: {
              type: "string",
              description: "Name of screen/feature to test (e.g., 'login', 'home', 'profile')",
            },
            testType: {
              type: "string",
              enum: ["navigation", "form", "authentication", "custom"],
              description: "Type of test to generate",
            },
            testScenario: {
              type: "string",
              description: "Specific test scenario description",
            },
          },
          required: ["projectPath", "screenName", "testType"],
        },
      },
      {
        name: "generate_test_suite",
        description: "Generate complete test suite for the entire Flutter app",
        inputSchema: {
          type: "object",
          properties: {
            projectPath: {
              type: "string",
              description: "Path to Flutter project",
            },
            coverage: {
              type: "string",
              enum: ["basic", "comprehensive", "critical-path"],
              description: "Test coverage level",
              default: "basic",
            },
          },
          required: ["projectPath"],
        },
      },
      {
        name: "analyze_widget",
        description: "Analyze a specific widget file to extract testable elements",
        inputSchema: {
          type: "object",
          properties: {
            widgetPath: {
              type: "string",
              description: "Full path to widget Dart file",
            },
          },
          required: ["widgetPath"],
        },
      },
    ];
  }

  private async handleAnalyzeApp(args: any) {
    const { projectPath } = args;
    const analysis = await this.analyzer.analyzeProject(projectPath);
    
    return {
      content: [
        {
          type: "text",
          text: `# Flutter App Analysis\n\n## Summary\n- **Screens Found:** ${analysis.screens.length}\n- **Controllers:** ${analysis.controllers.length}\n- **Models:** ${analysis.models.length}\n- **Routes:** ${Object.keys(analysis.routes).length}\n\n## Screens\n${analysis.screens.map(s => `- ${s.name} (${s.textFields.length} text fields, ${s.buttons.length} buttons)`).join('\n')}\n\n## Full Analysis\n\`\`\`json\n${JSON.stringify(analysis, null, 2)}\n\`\`\``,
        },
      ],
    };
  }

  private async handleGenerateTest(args: any) {
    const { projectPath, screenName, testType, testScenario } = args;
    
    // Analyze the screen
    const screenAnalysis = await this.analyzer.analyzeScreen(projectPath, screenName);
    
    // Generate test code
    const testCode = await this.generator.generateTest({
      screenName,
      testType,
      scenario: testScenario,
      screenAnalysis,
    });

    const fileName = `${screenName.toLowerCase().replace(/\s+/g, '_')}_test.dart`;

    return {
      content: [
        {
          type: "text",
          text: `# Generated Test\n\n**File:** \`integration_test/${fileName}\`\n\n\`\`\`dart\n${testCode}\n\`\`\`\n\n## Next Steps\n1. Save this code to \`integration_test/${fileName}\`\n2. Update import paths as needed\n3. Run: \`patrol test -t integration_test/${fileName}\``,
        },
      ],
    };
  }

  private async handleGenerateTestSuite(args: any) {
    const { projectPath, coverage = "basic" } = args;
    
    const analysis = await this.analyzer.analyzeProject(projectPath);
    const testSuite = await this.generator.generateTestSuite(analysis, coverage);

    return {
      content: [
        {
          type: "text",
          text: `# Generated Test Suite\n\n**Coverage Level:** ${coverage}\n**Total Tests:** ${testSuite.tests.length}\n\n${testSuite.tests.map((test: any, idx: number) => 
            `## Test ${idx + 1}: ${test.file}\n\n\`\`\`dart\n${test.content}\n\`\`\``
          ).join('\n\n')}`,
        },
      ],
    };
  }

  private async handleAnalyzeWidget(args: any) {
    const { widgetPath } = args;
    const widgetInfo = await this.analyzer.analyzeWidgetFile(widgetPath);

    return {
      content: [
        {
          type: "text",
          text: `# Widget Analysis\n\n**Path:** ${widgetPath}\n\n\`\`\`json\n${JSON.stringify(widgetInfo, null, 2)}\n\`\`\``,
        },
      ],
    };
  }

  async run(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Flutter Test Generator MCP server running on stdio");
  }
}

const server = new FlutterTestGeneratorServer();
server.run().catch(console.error);