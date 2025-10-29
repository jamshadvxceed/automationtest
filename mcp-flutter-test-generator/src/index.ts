#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from '@modelcontextprotocol/sdk/types.js';
import { z } from 'zod';

import { FlutterTestGenerator } from './generators/test-generator.js';
import { TestRunner } from './tools/test-runner.js';
import { UIActions } from './tools/ui-actions.js';
import { WaitActions } from './tools/wait-actions.js';
import { logger } from './utils/logger.js';

class FlutterTestMCPServer {
  private server: Server;
  private testGenerator: FlutterTestGenerator;
  private testRunner: TestRunner;
  private uiActions: UIActions;
  private waitActions: WaitActions;

  constructor() {
    this.server = new Server(
      {
        name: 'flutter-test-mcp',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.testGenerator = new FlutterTestGenerator();
    this.testRunner = new TestRunner();
    this.uiActions = new UIActions();
    this.waitActions = new WaitActions();

    this.setupToolHandlers();
    this.setupErrorHandling();
  }

  private setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'generate_flutter_test',
            description: '根据自然语言描述生成Flutter集成测试代码',
            inputSchema: {
              type: 'object',
              properties: {
                description: {
                  type: 'string',
                  description: '测试场景的自然语言描述，例如：点击登录按钮，输入用户名密码，验证登录成功'
                },
                testName: {
                  type: 'string',
                  description: '测试用例的名称'
                },
                projectPath: {
                  type: 'string',
                  description: 'Flutter项目的根路径'
                }
              },
              required: ['description', 'testName', 'projectPath']
            }
          },
          {
            name: 'run_integration_test',
            description: '执行Flutter集成测试',
            inputSchema: {
              type: 'object',
              properties: {
                projectPath: {
                  type: 'string',
                  description: 'Flutter项目的根路径'
                },
                testFile: {
                  type: 'string',
                  description: '测试文件路径（相对于项目根目录）'
                },
                device: {
                  type: 'string',
                  description: '运行测试的设备ID（可选）'
                }
              },
              required: ['projectPath', 'testFile']
            }
          },
          {
            name: 'find_element',
            description: '在Flutter应用中查找UI元素',
            inputSchema: {
              type: 'object',
              properties: {
                finder: {
                  type: 'string',
                  description: '元素查找方式：text, key, type, ancestor等'
                },
                value: {
                  type: 'string',
                  description: '查找的值，如文本内容、key名称等'
                }
              },
              required: ['finder', 'value']
            }
          },
          {
            name: 'tap_element',
            description: '点击Flutter应用中的UI元素',
            inputSchema: {
              type: 'object',
              properties: {
                finder: {
                  type: 'string',
                  description: '元素查找方式'
                },
                value: {
                  type: 'string',
                  description: '查找的值'
                }
              },
              required: ['finder', 'value']
            }
          },
          {
            name: 'enter_text',
            description: '在输入框中输入文本',
            inputSchema: {
              type: 'object',
              properties: {
                finder: {
                  type: 'string',
                  description: '输入框的查找方式'
                },
                value: {
                  type: 'string',
                  description: '查找的值'
                },
                text: {
                  type: 'string',
                  description: '要输入的文本'
                }
              },
              required: ['finder', 'value', 'text']
            }
          },
          {
            name: 'scroll',
            description: '执行滚动操作',
            inputSchema: {
              type: 'object',
              properties: {
                direction: {
                  type: 'string',
                  enum: ['up', 'down', 'left', 'right'],
                  description: '滚动方向'
                },
                distance: {
                  type: 'number',
                  description: '滚动距离（像素）',
                  default: 300
                },
                finder: {
                  type: 'string',
                  description: '可滚动元素的查找方式（可选）'
                },
                value: {
                  type: 'string',
                  description: '可滚动元素的查找值（可选）'
                }
              },
              required: ['direction']
            }
          },
          {
            name: 'wait_for_element',
            description: '等待元素出现',
            inputSchema: {
              type: 'object',
              properties: {
                finder: {
                  type: 'string',
                  description: '元素查找方式'
                },
                value: {
                  type: 'string',
                  description: '查找的值'
                },
                timeout: {
                  type: 'number',
                  description: '等待超时时间（秒）',
                  default: 10
                }
              },
              required: ['finder', 'value']
            }
          },
          {
            name: 'wait_for_text',
            description: '等待特定文本出现',
            inputSchema: {
              type: 'object',
              properties: {
                text: {
                  type: 'string',
                  description: '要等待的文本内容'
                },
                timeout: {
                  type: 'number',
                  description: '等待超时时间（秒）',
                  default: 10
                }
              },
              required: ['text']
            }
          },
          {
            name: 'delay',
            description: '延时等待指定时间',
            inputSchema: {
              type: 'object',
              properties: {
                seconds: {
                  type: 'number',
                  description: '延时秒数'
                }
              },
              required: ['seconds']
            }
          },
          {
            name: 'verify_text_exists',
            description: '验证页面中是否存在特定文本',
            inputSchema: {
              type: 'object',
              properties: {
                text: {
                  type: 'string',
                  description: '要验证的文本内容'
                },
                shouldExist: {
                  type: 'boolean',
                  description: '文本是否应该存在',
                  default: true
                }
              },
              required: ['text']
            }
          },
          {
            name: 'take_screenshot',
            description: '截取当前屏幕截图',
            inputSchema: {
              type: 'object',
              properties: {
                filename: {
                  type: 'string',
                  description: '截图文件名（可选）'
                }
              }
            }
          }
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'generate_flutter_test':
            return await this.handleGenerateTest(args);
          case 'run_integration_test':
            return await this.handleRunTest(args);
          case 'find_element':
            return await this.handleFindElement(args);
          case 'tap_element':
            return await this.handleTapElement(args);
          case 'enter_text':
            return await this.handleEnterText(args);
          case 'scroll':
            return await this.handleScroll(args);
          case 'wait_for_element':
            return await this.handleWaitForElement(args);
          case 'wait_for_text':
            return await this.handleWaitForText(args);
          case 'delay':
            return await this.handleDelay(args);
          case 'verify_text_exists':
            return await this.handleVerifyText(args);
          case 'take_screenshot':
            return await this.handleTakeScreenshot(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        logger.error(`Error executing tool ${name}:`, error);
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
        };
      }
    });
  }

  private async handleGenerateTest(args: any) {
    const result = await this.testGenerator.generateTest(
      args.description,
      args.testName,
      args.projectPath
    );
    
    return {
      content: [
        {
          type: 'text',
          text: `Flutter集成测试已生成：\n\n文件路径：${result.filePath}\n\n测试代码：\n\`\`\`dart\n${result.testCode}\n\`\`\``,
        },
      ],
    };
  }

  private async handleRunTest(args: any) {
    const result = await this.testRunner.runTest(
      args.projectPath,
      args.testFile,
      args.device
    );
    
    return {
      content: [
        {
          type: 'text',
          text: `测试执行${result.success ? '成功' : '失败'}：\n\n${result.output}`,
        },
      ],
    };
  }

  private async handleFindElement(args: any) {
    const result = this.uiActions.generateFindCode(args.finder, args.value);
    
    return {
      content: [
        {
          type: 'text',
          text: `查找元素的代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleTapElement(args: any) {
    const result = this.uiActions.generateTapCode(args.finder, args.value);
    
    return {
      content: [
        {
          type: 'text',
          text: `点击元素的代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleEnterText(args: any) {
    const result = this.uiActions.generateEnterTextCode(
      args.finder,
      args.value,
      args.text
    );
    
    return {
      content: [
        {
          type: 'text',
          text: `输入文本的代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleScroll(args: any) {
    const result = this.uiActions.generateScrollCode(
      args.direction,
      args.distance,
      args.finder,
      args.value
    );
    
    return {
      content: [
        {
          type: 'text',
          text: `滚动操作的代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleWaitForElement(args: any) {
    const result = this.waitActions.generateWaitForElementCode(
      args.finder,
      args.value,
      args.timeout || 10
    );
    
    return {
      content: [
        {
          type: 'text',
          text: `等待元素的代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleWaitForText(args: any) {
    const result = this.waitActions.generateWaitForTextCode(
      args.text,
      args.timeout || 10
    );
    
    return {
      content: [
        {
          type: 'text',
          text: `等待文本的代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleDelay(args: any) {
    const result = this.waitActions.generateDelayCode(args.seconds);
    
    return {
      content: [
        {
          type: 'text',
          text: `延时代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleVerifyText(args: any) {
    const result = this.uiActions.generateVerifyTextCode(
      args.text,
      args.shouldExist !== false
    );
    
    return {
      content: [
        {
          type: 'text',
          text: `验证文本的代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private async handleTakeScreenshot(args: any) {
    const result = this.uiActions.generateScreenshotCode(args.filename);
    
    return {
      content: [
        {
          type: 'text',
          text: `截图代码：\n\`\`\`dart\n${result}\n\`\`\``,
        },
      ],
    };
  }

  private setupErrorHandling() {
    this.server.onerror = (error) => {
      logger.error('Server error:', error);
    };

    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    logger.info('Flutter Test MCP Server started');
  }
}

const server = new FlutterTestMCPServer();
server.start().catch((error) => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});